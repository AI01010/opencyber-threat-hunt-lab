# Threat Hunt Lab: Part 2

[*(back to home)*](https://github.com/codepath/opencyber-threat-hunt-lab)

Lab Parts:

0. [Set up the lab environment using Docker.](./lab_part0.md)
1. [Learn: Threat Intelligence Feeds](./lab_part1.md)
2. [Apply: Hunting for Tor Activity](./lab_part2.md) (✅ You are here!)
3. [Challenge: Real-World Threat Hunting](./lab_part3.md)

## Part 2 | Apply: Hunting for Tor Activity

**Estimated Time:** 60 minutes

**Environment:** Your web browser (`http://localhost:8000`)

**Tools Needed:** Splunk (running in Docker — see [Part 0](./lab_part0.md) for setup) with `IOCs_Tor.csv` already uploaded from [Part 1](./lab_part1.md)

**[Back to home](https://github.com/codepath/opencyber-threat-hunt-lab)**

## Instructions

> [!IMPORTANT]
> This part requires `IOCs_Tor.csv` to already be in Splunk. Run this search with **All Time** selected to confirm:
>
> ```SPL
> source="IOCs_Tor.csv" | stats count
> ```
>
> If the count is 0, go back and complete [Part 1](./lab_part1.md) before continuing.

In Part 1, you loaded a threat intelligence feed of known **Tor** IP addresses into Splunk. Tor (The Onion Router) is an anonymizing network that routes traffic through a series of relays to obscure a user's identity and location. It has legitimate privacy uses, but threat actors also use it to hide the origin of attacks — which is why SOC analysts watch for it. A connection from inside your network to a known Tor exit node is worth investigating.

In this part, you'll bring in a network proxy log — a record of outbound web traffic from machines on your network — and build a search that flags any connections to Tor IPs.

This part introduces three new SPL commands:

| Command | What it does |
|---|---|
| `where` | Filters results based on a condition, applied *after* aggregation |
| `values(field) as alias` | Collects all unique values of a field across matching events into one row |
| `mvcount(field)` | Counts the number of items in a multi-value field (the result of `values()`) |

### Step 1: Upload the Network Proxy Log

A network proxy log records outbound web traffic from machines on your network — every connection attempt, the destination IP, the user, and the computer making the request. This is exactly the kind of data that would capture a user connecting to a Tor node.

> [!NOTE]
> If you're resuming a previous session, this file may already be in Splunk. Run the search below with **All Time** selected before uploading — if the count is 0, proceed with the upload. Otherwise, skip ahead to Step 2.
>
> ```SPL
> source="TrafficLog_Tor.csv" | stats count
> ```

- [ ] Download the network proxy log to your computer:
  **[TrafficLog_Tor.csv](https://raw.githubusercontent.com/codepath/cyb102-file-storage/main/threat-hunt/TrafficLog_Tor.csv)**

- [ ] Upload it to Splunk using **Settings → Add Data → Upload**, the same way you uploaded the Tor feed in Part 1.
  - You can accept all default values this time — no need to change the Host field.

- [ ] Once uploaded, run a quick search to confirm the data is there:

  ```SPL
  source="TrafficLog_Tor.csv"
  ```

- [ ] Browse the **Interesting Fields** panel. Note the available fields — especially `IP Address`, `Computer Name`, `User Agent String`, `Date`, and `Time`.

🎯 **Checkpoint 1**: You should see network proxy events, with fields representing outbound connections from machines on your network.

### Step 2: The Core Question

You now have two datasets in Splunk:

| Source | What it contains |
|---|---|
| `IOCs_Tor.csv` | Known Tor network IP addresses |
| `TrafficLog_Tor.csv` | Outbound connections from machines on your network |

The question you want to answer: **Did any machine on our network connect to a known Tor IP address?**

To answer it, you need to find IP addresses that appear in **both** sources. This is called **event correlation** — one of the most valuable things a SIEM can do.

### Step 3: Build the Correlation Search

Let's build this up step by step.

#### 3.1: Search across both sources

The `OR` operator lets you search multiple sources at once:

```SPL
source="IOCs_Tor.csv" OR source="TrafficLog_Tor.csv"
```

Run this. You should see events from both files mixed together. Not useful yet — but this is the foundation.

#### 3.2: Count IP address appearances

Now aggregate by `IP Address` to see how many times each IP appears across both sources:

```SPL
source="IOCs_Tor.csv" OR source="TrafficLog_Tor.csv"
| stats count by "IP Address"
```

Most IPs will have a count of 1 — they appear in only one source. An IP with a count greater than 1 appears in *both*, meaning it's a known Tor node **and** it shows up in your network traffic.

#### 3.3: Filter for matches

Add a `where` clause to keep only the IPs that appear in more than one source:

```SPL
source="IOCs_Tor.csv" OR source="TrafficLog_Tor.csv"
| stats count by "IP Address"
| where count > 1
```

> [!NOTE]
> `where` filters results *after* aggregation, unlike field filters that apply at search time. Think of it as the SPL equivalent of SQL's `HAVING` clause.

🎯 **Checkpoint 2**: You should see at least one IP address that appears in both the Tor feed and the network proxy log. That's your lead.

### Step 4: Enrich the Results

Knowing *that* a match exists is useful. Knowing *who* was using it, *from which machine*, and *when* is actionable. Let's enrich the search.

The `values()` function collects all unique values of a field across multiple events and combines them into a single result row. Combined with `mvcount()`, you can count how many distinct sources an IP appeared in — a more robust way to identify cross-source matches than a simple count:

```SPL
source="IOCs_Tor.csv" OR source="TrafficLog_Tor.csv"
| stats values(source) as sources,
        values("Computer Name") as ComputerName,
        values("User Agent String") as UserAgent,
        values(Date) as Date,
        values(Time) as Time
  by "IP Address"
| where mvcount(sources) > 1
| table "IP Address", ComputerName, UserAgent, Date, Time
```

> [!NOTE]
> `values(source) as sources` collects the source filenames for each IP into a multi-value field called `sources`. `mvcount(sources) > 1` then means "this IP appeared in more than one source file" — which is exactly what indicates a match between the threat feed and the network log.

Run this search. For each matching IP, you'll now see:
- Which computer made the connection
- What browser or application was used (User Agent)
- When the connection occurred

🎯 **Checkpoint 3**: You should be able to identify the computer and user responsible for connecting to a Tor node, along with the timing of the activity.

### Step 5: Build a Threat Monitoring Dashboard

In a real SOC, you wouldn't run this search manually every time — you'd have it running continuously on a dashboard, alerting you the moment new activity appears.

- [ ] Navigate to **Dashboards** and create a new dashboard titled **"Threat Intelligence Monitoring"**.

> [!NOTE]
> Splunk will ask you to choose between **Classic Dashboards** and **Dashboard Studio**. Choose **Classic Dashboards** — the instructions below use that interface.
- [ ] Add a panel using the enriched search from Step 4.
  - Click **Add Panel** → **New** → **Statistics Table**
  - Paste in the search, set the time range to **All Time**
  - Title the panel **"Tor Activity Detected"**
- [ ] Save the dashboard.

> [!TIP]
> In a production environment, this dashboard would refresh automatically as new proxy logs stream in, and you could configure alerts to notify the on-call analyst when a match is found. That's how SOCs catch threats in near-real time.

🎯 **Checkpoint 4**: You should have a monitoring dashboard that shows any network connections matching the Tor threat feed.

In [Part 3](./lab_part3.md), you'll apply the same correlation technique to investigate a real-world threat: the SolarWinds supply chain attack.
