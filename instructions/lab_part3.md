# Threat Hunt Lab: Part 3

[*(back to home)*](https://github.com/codepath/opencyber-threat-hunt-lab)

Lab Parts:

0. [Set up the lab environment using Docker.](./lab_part0.md)
1. [Learn: Threat Intelligence Feeds](./lab_part1.md)
2. [Apply: Hunting for TOR Activity](./lab_part2.md)
3. [Challenge: A Study in Sapphire](./lab_part3.md) (✅ You are here!)

## Part 3 | Challenge: A Study in Sapphire

**Estimated Time:** 90 minutes

**Environment:** Your web browser (`http://localhost:8000`)

**Tools Needed:** Splunk (running in Docker — see [Part 0](./lab_part0.md) for setup)

**[Back to home](https://github.com/codepath/opencyber-threat-hunt-lab)**

## Instructions

### Background

In December 2020, security researchers discovered one of the most significant supply chain attacks in history. Threat actors — later attributed to a Russian intelligence operation — had compromised SolarWinds, a company whose network monitoring software was used by thousands of organizations including US government agencies and Fortune 500 companies.

The attackers embedded malicious code into a legitimate SolarWinds software update. When customers installed the update, the malware quietly established contact with attacker-controlled infrastructure. Organizations had unknowingly invited the threat in through their own software update process.

In this challenge, you'll use the same technique you learned in Part 2 to hunt for signs of a SolarWinds compromise in a set of network logs from PathCode Inc.

### Files

Download both files to your computer before starting:

| File | Description | Download |
|---|---|---|
| `SolarWindsIOCs.csv` | Known IP addresses and domains associated with the SolarWinds attack | [Download](https://raw.githubusercontent.com/codepath/cyb102-file-storage/main/SolarWindsIOCs.csv) |
| `NetworkProxyLog02.csv` | Network proxy logs from PathCode Inc. | [Download](https://raw.githubusercontent.com/codepath/cyb102-file-storage/main/NetworkProxyLog02.csv) |

*(Right-click each link and choose "Save link as..." to download.)*

### Step 1: Upload Both Files to Splunk

> [!NOTE]
> If you're resuming a previous session, these files may already be in Splunk. Run each search below with **All Time** selected before uploading — if you get results for a file, skip that upload.
>
> ```SPL
> source="SolarWindsIOCs.csv" | stats count
> ```
>
> ```SPL
> source="NetworkProxyLog02.csv" | stats count
> ```

- [ ] Upload `SolarWindsIOCs.csv` to Splunk using **Settings → Add Data → Upload**.
  - Accept all defaults.
- [ ] Upload `NetworkProxyLog02.csv` the same way.
- [ ] Confirm both are searchable:

  ```SPL
  source="SolarWindsIOCs.csv" OR source="NetworkProxyLog02.csv"
  ```

🎯 **Checkpoint 1**: Both datasets should return events.

> [!TIP]
> Before jumping to the correlation search, spend a few minutes exploring each file separately. What fields does `SolarWindsIOCs.csv` have? What fields does `NetworkProxyLog02.csv` share with it? The shared field is what makes the correlation possible.

### Step 2: Hunt for Compromised Systems

Adapt the correlation search from Part 2 to cross-reference the SolarWinds IOCs against PathCode's network logs.

> [!TIP]
> The search structure is the same as Part 2 — only the source names change. Refer back to [Part 2 Step 4](./lab_part2.md) if you need a refresher on `values()` and `mvcount()`.

<details>
  <summary>💡 Stuck? Click for a hint.</summary>

  Start with the simple version first to confirm you're getting matches:

  ```SPL
  source="SolarWindsIOCs.csv" OR source="NetworkProxyLog02.csv"
  | stats count by "IP Address"
  | where count > 1
  ```

  Once you have matches, enrich the results using the `values()` pattern from Part 2 to pull in `Computer Name`, `Date`, and `Time`.

</details>

There are **three matching IP addresses** in total. You need to find **at least two** to complete this challenge.

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

This step reflects a real SOC workflow: you find a match in your data, then corroborate it with external sources before escalating.

> [!TIP]
> Some IPs may no longer be flagged — that's expected and worth noting. An IP that was malicious in 2020 and is now clean doesn't mean the historical connection was benign; it means the infrastructure has changed. This is why current threat feeds matter.

🎯 **Checkpoint 3**: For each matched IP, you should have a VirusTotal result and a note on its current reputation.

### Step 5: Build a Monitoring Dashboard

- [ ] Create a new Splunk dashboard titled **"SolarWinds IOC Monitor"**.
- [ ] Add a panel using your enriched correlation search, showing any matches between `SolarWindsIOCs.csv` and `NetworkProxyLog02.csv`.
  - Set the time range to **All Time** for this static dataset.
  - Select **Statistics Table** as the visualization.
- [ ] Save the dashboard.

🎯 **Checkpoint 4**: You should have a dashboard that surfaces any PathCode network activity matching known SolarWinds IOCs.

### Stretch: Add a Second Threat Source

Want to go further?

- [ ] Find a public threat intelligence feed online (try searching "free threat feed CSV" or ask an AI assistant for suggestions).
- [ ] Import it into Splunk and search for matches against either `NetworkProxyLog01.csv` or `NetworkProxyLog02.csv`.
- [ ] Document what you found — even if the answer is "no matches." A null result is still useful: it means your network logs don't show activity associated with that threat source, which is worth knowing.

> [!TIP]
> Useful starting points: [Awesome Threat Intelligence](https://github.com/hslatman/awesome-threat-intelligence) is a curated list of public feeds covering a wide range of threat types.
