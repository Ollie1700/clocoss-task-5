# CLOCOSS Distributed Worker App by UP690316

## Introduction

This is a simple bash script for use on gcloud VMs that will automatically execute the following:
1. Clone [https://github.com/portsoc/clocoss-master-worker]
2. Start the server
3. Create **X** number of worker VMs
4. Wait until all 100 tasks have been completed
5. Remove server code
6. Kill worker VMs

## How to use

```bash
git clone https://github.com/Ollie1700/clocoss-distributed-worker-app;
cd clocoss-distributed-worker-app;
bash signoff-1.sh;
```
