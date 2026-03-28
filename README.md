# Threat Hunt Lab

This is the README documentation for the Threat Hunt Lab, produced and maintained by [CodePath.org](https://codepath.org).

## Quick Start

Want to jump into the lab? Navigate to the [Part 0 Instructions](./instructions/lab_part0.md) to get started!

## About this Lab

The Threat Hunt Lab teaches you how to use threat intelligence feeds to proactively hunt for malicious activity in network logs. You'll load real-world threat data into Splunk, write correlation searches that cross-reference it against network proxy logs, and investigate two separate real-world incidents: the SolarWinds supply chain compromise (2020) and a Scattered Spider social engineering campaign (2024).

### Learning Objectives

- Understand what threat intelligence feeds are and how SOC analysts use them
- Upload and search data in Splunk using the Add Data workflow
- Write SPL correlation searches to find indicators that appear across multiple datasets
- Apply threat hunting techniques to two distinct real-world attack scenarios
- Evaluate threat infrastructure using VirusTotal and reason about how IOC relevance changes over time

### Lab Activities

0. [Set up the lab environment using Docker.](./instructions/lab_part0.md)
1. [Learn: Threat Intelligence Feeds](./instructions/lab_part1.md)
2. [Apply: Hunting for TOR Activity](./instructions/lab_part2.md)
3. [Challenge: Real-World Threat Hunting](./instructions/lab_part3.md)

## Technical Details

### Provided Tools

Students interact with Splunk entirely through a web browser at `http://localhost:8000`. No command-line tools are required beyond Docker to start the container.

The Docker image includes:

- **Splunk Enterprise 9.0.4** — pre-configured with admin credentials and a Free license
- **No pre-indexed data** — uploading threat intelligence data into Splunk is a core learning activity of this lab. Students download CSV files and ingest them through Splunk's Add Data UI.

### Running the Lab

```bash
docker run --rm -it -p 8000:8000 -v threat-hunt-data:/opt/splunk/var ghcr.io/codepath/opencyber-threat-hunt-lab:latest
```

> **Note:** The named volume (`threat-hunt-data`) persists data you upload between sessions. Your work is safe if you stop and restart the container.
