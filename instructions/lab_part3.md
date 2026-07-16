# Threat Hunt Lab: Part 3

[*(back to home)*](https://github.com/codepath/opencyber-threat-hunt-lab)

Lab Parts:

0. [Set up the lab environment using Docker.](./lab_part0.md)
1. [Learn: Threat Intelligence Feeds](./lab_part1.md)
2. [Apply: Hunting for Tor Activity](./lab_part2.md)
3. [Challenge: Real-World Threat Hunting](./lab_part3.md) (✅ You are here!)

## Part 3 | Challenge: Real-World Threat Hunting

**Estimated Time:** 90 minutes

**Environment:** Your web browser (`http://localhost:8000`)

**Tools Needed:** Splunk (running in Docker — see [Part 0](./lab_part0.md) for setup)

**[Back to home](https://github.com/codepath/opencyber-threat-hunt-lab)**

## Instructions

PathCode Inc.'s security team has flagged suspicious outbound traffic across two separate time periods. You've been handed two sets of network logs and two threat intelligence feeds. They're unrelated incidents — different threat actors, different methods, different years. Your job is to investigate both.

---

## Investigation 1: The SolarWinds Compromise

### Background

In December 2020, security researchers discovered one of the most significant supply chain attacks in history. Threat actors — later attributed to a Russian intelligence operation — had compromised SolarWinds, a company whose network monitoring software was used by thousands of organizations including US government agencies and Fortune 500 companies.

The attackers embedded malicious code into a legitimate SolarWinds software update. When customers installed the update, the malware quietly established contact with attacker-controlled infrastructure. Organizations had unknowingly invited the threat in through their own software update process.

### Files

Download both files to your computer before starting:

| File | Description | Download |
|---|---|---|
| `IOCs_SolarWinds.csv` | Known IP addresses associated with the SolarWinds attack | [Download](https://raw.githubusercontent.com/codepath/cyb102-file-storage/main/threat-hunt/IOCs_SolarWinds.csv) |
| `TrafficLog_SolarWinds.csv` | Network proxy logs from PathCode Inc. (2020) | [Download](https://raw.githubusercontent.com/codepath/cyb102-file-storage/main/threat-hunt/TrafficLog_SolarWinds.csv) |

*(Right-click each link and choose "Save link as..." to download.)*

### Step 1: Upload Both Files to Splunk

> [!NOTE]
> If you're resuming a previous session, these files may already be in Splunk. Run each search below with **All Time** selected before uploading — if the count is 0, proceed with the upload. Otherwise, skip that file.
>
> ```SPL
> source="IOCs_SolarWinds.csv" | stats count
> ```
>>> 43
> ```SPL
> source="TrafficLog_SolarWinds.csv" | stats count
> ```
>>> 1000

- [X] Upload `IOCs_SolarWinds.csv` to Splunk using **Settings → Add Data → Upload**.
  - Accept all defaults.
- [X] Upload `TrafficLog_SolarWinds.csv` the same way.
- [X] Confirm both are searchable:

  ```SPL
  source="IOCs_SolarWinds.csv" OR source="TrafficLog_SolarWinds.csv"
  ```

🎯 **Checkpoint 1**: Both datasets should return events.

> [!TIP]
> If your searches return 0 results, check two things: make sure the time range picker is set to **All Time**, and switch the search mode from **Smart** to **Verbose**. Smart mode sometimes skips field extraction for exploratory searches.

> [!TIP]
> Before jumping to the correlation search, spend a few minutes exploring each file separately. What fields does `IOCs_SolarWinds.csv` have? What fields does `TrafficLog_SolarWinds.csv` share with it? The shared field is what makes the correlation possible.

### Step 2: Hunt for Compromised Systems

Adapt the correlation search from Part 2 to cross-reference the SolarWinds IOCs against PathCode's network logs.

> [!TIP]
> The search structure is the same as Part 2 — only the source names change. Refer back to [Part 2 Step 4](./lab_part2.md) if you need a refresher on `values()` and `mvcount()`.

<details>
  <summary>Hint: not sure where to start?</summary>

  Review the correlation search you built in [Part 2, Steps 3–4](./lab_part2.md). How can you adapt that search to help you here?

</details>

There are **three matching IP addresses** in total. You need to find **at least two** to complete this investigation.

🎯 **Checkpoint 2**: You should have at least two IP address matches between the SolarWinds IOC list and PathCode's network logs.

### Step 3: Document Your Findings

For each matching IP you found, record:

- [ ] The IP address
- [ ] The date(s) and time(s) the connection occurred
- [ ] The computer name(s) associated with the event

> [!NOTE]
> You may find more than one event per IP. If so, record all of them — multiple connections to the same IOC over time can indicate persistence or ongoing communication with attacker infrastructure.

### Step 4: Investigate on VirusTotal

Threat intelligence ages. An IP that was actively malicious in 2020 may have been taken down, reassigned, or cleaned up since.

- [ ] For each matching IP, search for it on [VirusTotal](https://www.virustotal.com).
- [ ] Note whether the IP is still flagged as malicious, and by how many vendors.

> [!TIP]
> Some IPs may no longer be flagged — that's expected and worth noting. An IP that was malicious in 2020 and is now clean doesn't mean the historical connection was benign; it means the infrastructure has changed. This is why current threat feeds matter.

🎯 **Checkpoint 3**: For each matched IP, you should have a VirusTotal result and a note on its current reputation.

### Step 5: Build a Monitoring Dashboard

- [ ] Create a new Splunk dashboard titled **"SolarWinds IOC Monitor"** (choose **Classic Dashboards** when prompted).
- [ ] Add a panel using your enriched correlation search, showing any matches between `IOCs_SolarWinds.csv` and `TrafficLog_SolarWinds.csv`.
  - Set the time range to **All Time** for this static dataset.
  - Select **Statistics Table** as the visualization.
- [ ] Save the dashboard.

🎯 **Checkpoint 4**: You have a dashboard surfacing PathCode network activity that matches known SolarWinds IOCs. Move on to Investigation 2.

---

## Investigation 2: Scattered Spider

### Background

Scattered Spider is a threat actor known for sophisticated social engineering attacks. Unlike nation-state groups that rely on custom malware, they typically start with a phone call — impersonating IT helpdesk staff, sometimes using AI-generated voice tools to sound more convincing, to trick employees into resetting their credentials or approving MFA requests. Once inside, they use legitimate infrastructure to move quietly through the network.

In 2024, PathCode's security team identified suspicious outbound connections in their proxy logs. They've handed you a threat intelligence feed of known Scattered Spider indicators and the relevant network logs. Investigate.

### Files

| File | Description | Download |
|---|---|---|
| `IOCs_ScatteredSpider.csv` | Known indicators of compromise from Scattered Spider campaigns | [Download](https://raw.githubusercontent.com/codepath/cyb102-file-storage/main/threat-hunt/IOCs_ScatteredSpider.csv) |
| `TrafficLog_ScatteredSpider.csv` | Network proxy logs from PathCode Inc. (2024) | [Download](https://raw.githubusercontent.com/codepath/cyb102-file-storage/main/threat-hunt/TrafficLog_ScatteredSpider.csv) |

*(Right-click each link and choose "Save link as..." to download.)*

### Step 1: Upload Both Files to Splunk

> [!NOTE]
> If you're resuming a previous session, these files may already be in Splunk. Run each search below with **All Time** selected before uploading — if the count is 0, proceed with the upload. Otherwise, skip that file.
>
> ```SPL
> source="IOCs_ScatteredSpider.csv" | stats count
> ```
>
> ```SPL
> source="TrafficLog_ScatteredSpider.csv" | stats count
> ```

- [ ] Upload `IOCs_ScatteredSpider.csv` to Splunk.
- [ ] Upload `TrafficLog_ScatteredSpider.csv` the same way.
- [ ] Confirm both are searchable:

  ```SPL
  source="IOCs_ScatteredSpider.csv" OR source="TrafficLog_ScatteredSpider.csv"
  ```

🎯 **Checkpoint 5**: Both datasets return events.

### Step 2: Hunt for Evidence

Use what you've learned to find connections between PathCode's 2024 network traffic and known Scattered Spider infrastructure. There are matches to find.

> [!NOTE]
> The proxy logs for this investigation record outbound web traffic differently than the SolarWinds logs. Explore the fields in each dataset before writing your search — the field you need to correlate on may not be the same one you used in Investigation 1.

🎯 **Checkpoint 6**: You should have at least one match between the Scattered Spider IOC list and PathCode's network logs.

### Step 3: Document Your Findings

For each match you found, record:

- [ ] The indicator value
- [ ] The date(s) and time(s) the connection occurred
- [ ] The computer name(s) associated with the event

### Step 4: Investigate on VirusTotal

- [ ] For each matched indicator, search for it on [VirusTotal](https://www.virustotal.com).
- [ ] Note whether it is still flagged as malicious, and by how many vendors.

🎯 **Checkpoint 7**: For each matched indicator, you should have a VirusTotal result and a note on its current status.

---

## Final Analysis

Finding a match in Splunk is only half the job. In a real SOC, threat hunters are expected to produce written summaries of their findings — translating technical results into something that security leadership, legal, and compliance teams can act on. A match against an IOC list means nothing to a CISO unless you can explain what systems were involved, when, and what it implies about the organization's exposure. This is what that looks like.

You've now completed two investigations using the same fundamental technique against two very different attacks. Write a short analysis (3–5 sentences) that addresses the following:

- [ ] What did you find in each investigation — how many systems were affected, and over what time period?
- [ ] Compare the VirusTotal results across both investigations. What does the difference (or similarity) tell you about how threat infrastructure ages?
- [ ] These were two separate incidents, years apart. What does that suggest about PathCode's security posture?

> [!NOTE]
> There's no single correct answer here. What matters is that your analysis reflects what you actually found in the data and shows you thought about what it means.

🎯 **Checkpoint 8**: You have a written analysis that synthesizes findings from both investigations.

---

### Tips for Success

- **Getting 0 results from a search?** Check two things: make sure the time range picker is set to **All Time**, and switch the search mode from **Smart** to **Verbose**. Smart mode sometimes skips field extraction for exploratory searches.
- **Not sure what fields are available?** Run a bare search (e.g., `source="IOCs_SolarWinds.csv"`) and open the **Interesting Fields** panel on the left. This shows every field Splunk parsed from your data — useful for finding the shared field before writing a correlation search.
- **Correlation search returning nothing?** The join field has to match exactly — including case and spacing. If `IP Address` in one file is stored as `ip_address` in another, the join will silently fail. Check field names in both datasets separately before combining them.
- **VirusTotal showing "clean" for a known malicious IP?** That's expected and worth noting in your analysis. Threat actors rotate infrastructure quickly — an IP flagged in 2020 may be legitimately reassigned by now. The age of the IOC matters.
- **Splunk dashboard panel showing no data?** Make sure your search uses **All Time** — dashboard panels default to a shorter time window that may exclude your uploaded data.
