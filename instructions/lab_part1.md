# Threat Hunt Lab: Part 1

[*(back to home)*](https://github.com/codepath/opencyber-threat-hunt-lab)

Lab Parts:

0. [Set up the lab environment using Docker.](./lab_part0.md)
1. [Learn: Threat Intelligence Feeds](./lab_part1.md) (✅ You are here!)
2. [Apply: Hunting for TOR Activity](./lab_part2.md)
3. [Challenge: A Study in Sapphire](./lab_part3.md)

## Part 1 | Learn: Threat Intelligence Feeds

**Estimated Time:** 45 minutes

**Environment:** Your web browser (`http://localhost:8000`)

**Tools Needed:** Splunk (running in Docker — see [Part 0](./lab_part0.md) for setup)

**[Back to home](https://github.com/codepath/opencyber-threat-hunt-lab)**

## Instructions

### Step 0: What is a Threat Intelligence Feed?

In the Splunk Fundamentals lab, you searched log data that was already in your SIEM. But where does the knowledge of *what to look for* come from? That's where **threat intelligence** enters the picture.

Threat intelligence feeds are continuous or periodic streams of information about known threats — malicious IP addresses, suspicious domains, file hashes associated with malware, and more. Organizations that detect attacks share what they found so others can defend against the same threats. In a real SOC, analysts integrate these feeds into their SIEM so searches can automatically flag activity that matches known bad actors.

<details>
  <summary>What types of threat feeds exist?</summary>

  Feeds vary widely depending on their source and purpose:

  - **IP reputation lists** — known malicious or suspicious IP addresses
  - **Domain blocklists** — domains associated with phishing, malware distribution, or C2 infrastructure
  - **File hash feeds** — MD5/SHA hashes of known malicious files
  - **Vulnerability feeds** — newly disclosed CVEs and affected software versions
  - **Sector-specific feeds** — some feeds are shared only within an industry (healthcare, finance, government)

  Some feeds update continuously in real time; others are static snapshots. In this lab we'll work with a **static feed** — ideal for learning how to ingest and query intelligence data.

</details>

<details>
  <summary>Why does this matter for a SOC analyst?</summary>

  Threat feeds let you stop searching blindly and start searching purposefully. Instead of asking "is anything weird happening?", you can ask "has any activity on our network matched a known bad actor?" That's a much more actionable question — and it's one your SIEM can answer automatically once the feed is loaded.

</details>

### Step 1: Download the Threat Feed

For this lab, we'll work with a feed of IP addresses associated with the **TOR network** — an anonymizing network often used by privacy-conscious users, but also by threat actors trying to hide the origin of attacks.

- [ ] Download the threat feed file to your computer:
  **[TorList.csv](https://raw.githubusercontent.com/codepath/cyb102-file-storage/main/TorList.csv)**
  *(Right-click the link and choose "Save link as..." to download the file.)*

### Step 2: Upload the Feed to Splunk

> [!NOTE]
> If you're resuming a previous session, this file may already be in Splunk. Run the search below with **All Time** selected before uploading — if you get results, skip ahead to Step 3.
>
> ```SPL
> source="TorList.csv" | stats count
> ```

Unlike the Splunk Fundamentals lab, this one has no pre-loaded data. That's intentional. SOC analysts import new threat feeds into their SIEM all the time, and this upload workflow is what that looks like in practice.

- [ ] In Splunk, navigate to **Settings** → **Add Data**.
- [ ] Click **Upload** (the option for uploading files from your computer).
- [ ] Click **Select File** and choose the `TorList.csv` file you downloaded.
- [ ] Click **Next**.

#### Source Type

Splunk needs to know how to parse the file. Since this is a CSV:

- [ ] In the **Set Source Type** step, confirm the source type is set to **csv**. Splunk may auto-detect this — if so, you'll see a preview of the parsed fields. If not, search for and select `csv` manually.
- [ ] Click **Next**.

#### Input Settings

This screen lets you control how Splunk labels the incoming data.

- [ ] Find the **Host** field. Change the value from the default (usually the filename) to **`Threat Feed`**.
  - This makes it easy to distinguish threat intelligence data from operational logs when searching.
- [ ] Leave all other settings at their defaults.
- [ ] Click **Review**, then **Submit**.

🎯 **Checkpoint 1**: Splunk should confirm the upload succeeded. Click **Start Searching** to go directly to the Search & Reporting app.

### Step 3: Explore the Feed

Let's see what we're working with.

- [ ] Run the following search with **All Time** selected:

  ```SPL
  source="TorList.csv"
  ```

- [ ] Expand a few events and browse the **Interesting Fields** panel on the left.

You should see fields including `IP Address`, `Country`, and possibly others. These are the columns from the CSV, parsed as searchable fields.

> [!NOTE]
> Field names that contain spaces (like `IP Address`) must be quoted in SPL searches: `"IP Address"`. You'll see this pattern throughout this lab.

- [ ] How many events (IP addresses) are in this feed? Note the count — you'll reference it later.

- [ ] Try a few searches to explore the data:
  - Which countries have the most TOR exit nodes? (`| stats count by Country | sort -count`)
  - Are any IP addresses duplicated in the feed?

🎯 **Checkpoint 2**: You should have a working sense of what the TOR feed contains — a list of known TOR network IP addresses with associated metadata.

### Step 4: Why Does TOR Activity Matter?

You now have a list of known TOR IP addresses in your SIEM. On its own, that's just reference data. The power comes from **cross-referencing it against your own network logs** — which is exactly what we'll do in [Part 2](./lab_part2.md).

> [!TIP]
> The TOR feed is a simple example of threat intelligence. In a production environment, you'd also ingest feeds covering malware C2 infrastructure, phishing domains, and attacker infrastructure — all searchable the same way.

You've completed Part 1! In [Part 2](./lab_part2.md), you'll bring in network proxy logs and build a search that finds any TOR activity on your network.
