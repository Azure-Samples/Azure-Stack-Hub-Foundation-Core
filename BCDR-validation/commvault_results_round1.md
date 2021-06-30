# Commvault

## Overview

The software platform is an enterprise level, integrated data and information management solution, built from the ground up on a single platform and unified code base. All functions share the same back-end technologies to deliver the unparalleled advantages and benefits of a truly holistic approach to protecting, managing, and accessing data. The software contains modules to protect and archive, analyze, replicate, and search your data, which all share a common set of back-end services and advanced capabilities, seamlessly interacting with one another. This addresses all aspects of data management in the enterprise, while providing infinite scalability and unprecedented control of data and information.

## Documentation

 - Links to product documentation
     - [Microsoft Azure Stack Hub (commvault.com)](https://documentation.commvault.com/commvault/v11/article?p=86486.htm)
     - Guides for installation and configuration (especially the ones used for the tests below basic/medium/heavy)

 - Contact points

## Test scenarios

| Scenario                    | Azure Stack Hub Version (each stamp) | 3P version | test     | Outcome (time, issues, other) |
|-----------------------------|---------------------------------|------------|----------|-------------------------------|
| AzStackHub to AzStackHub    | 1.2102.11.40                    |            |          |                               |
| Migrate between AzStackHubs | 1.2102.11.40                    |            |          |                               |
| Migrate to AzStackHub       | 1.2102.11.40                    |            | (origin) |                               |

**Test Results**

Environment:  Commvault Version SP23

CommServe + WebServer packages Installed on Azure Stack VM with Size Standard F8s_v2 (8 vcpus, 16 GiB memory)

VSA and Media agent package installed on Azure Stack VM with Standard F16s_v2 (16 vcpus, 32 GiB memory)

CommServe, Media Agent/VSA access nodes was deployed on Windows Server 2016 Datacenter

Commvault Documentation Link:

<https://documentation.commvault.com/11.23/essential/121684_microsoft_azure_stack_hub.html>

AzStackHub Version :  2102

Installation guide to install Commserve: 

<https://documentation.commvault.com/11.23/essential/86625_quick_start_guide.html>

Documentation link for Virtual Server Agent:

<https://documentation.commvault.com/11.23/essential/119353_virtualization_and_cloud.html>

Replication documentation:

<https://documentation.commvault.com/11.23/disaster_recovery/127528_use_cases_for_disaster_recovery.html>

Getting started for Disaster Recovery

<https://documentation.commvault.com/11.23/disaster_recovery/128015_getting_started_with_disaster_recovery.html>

Results:

### Scenario 1: - Same Stamp results.

VMs in Stamp A; VSA access node in Stamp A; Library is configured on Stamp A

VSA Access node and MA on same box config: - **Standard F16s_v2 (16 vcpus, 32 GiB memory)**

| **VM Group**       | **Backup Type** | **Start Time**  | **End Time**    | **Duration** | **Size of Application** | **Average Throughput** | **Data Written** | **Savings Percentage** | **Transfer Time** |
|--------------------|-----------------|-----------------|-----------------|--------------|-------------------------|------------------------|------------------|------------------------|-------------------|
| otherVMsizes-10VMs | Full            | 5/12/2021 11:49 | 5/12/2021 13:14 | 1:24:52      | 322.31 GB               | 243.15 GB/hr           | 103.72 GB        | 67                     | 1:19:32           |
| HLF4S-100VMs       | Full            | 5/12/2021 11:49 | 5/12/2021 13:02 | 1:13:21      | 273.73 GB               | 287.04 GB/hr           | 40.97 GB         | 85                     | 0:57:13           |
| HLF2SV2            | Full            | 5/12/2021 11:49 | 5/12/2021 14:49 | 3:00:12      | 1.23 TB                 | 446.24 GB/hr           | 480.72 GB        | 61                     | 2:48:50           |
| HLD3V2-20          | Full            | 5/12/2021 11:49 | 5/12/2021 14:09 | 2:20:54      | 649.92 GB               | 303.98 GB/hr           | 177.9 GB         | 72                     | 2:08:17           |
| HLA1V2-100VMs      | Full            | 5/12/2021 11:48 | 5/12/2021 15:22 | 3:33:33      | 1.65 TB                 | 522.08 GB/hr           | 532.28 GB        | 68                     | 3:14:28           |

### Scenario 2: - Stamp A to Stamp B

| VMs In Stamp A                                                                                                           |
|--------------------------------------------------------------------------------------------------------------------------|
| Proxy and Media Agent in Stamp B                                                                                         |
| Storage library is on Stamp B  VSA and Media agent on same machine, config: - Standard F16s_v2 (16 vcpus, 32 GiB memory) |

| **VM Group**       | **Backup Type** | **Start Time** | **End Time**   | **Duration** | **Size of Application** | **Average Throughput** | **Data Written** | **Savings Percentage** | **Transfer Time** |
|--------------------|-----------------|----------------|----------------|--------------|-------------------------|------------------------|------------------|------------------------|-------------------|
| HLF4S-100VMs       | Full            | 5/14/2021 6:00 | 5/14/2021 7:40 | 1:40:16      | 291.09 GB               | 335.55 GB/hr           | 45.31 GB         | 84                     | 0:52:03           |
| HLF2SV2            | Full            | 5/14/2021 6:00 | 5/14/2021 9:28 | 3:28:12      | 1.33 TB                 | 434.16 GB/hr           | 512.04 GB        | 62                     | 3:08:30           |
| HLD3V2-20          | Full            | 5/14/2021 5:59 | 5/14/2021 8:35 | 2:35:22      | 649.99 GB               | 297.52 GB/hr           | 153.84 GB        | 76                     | 2:11:05           |
| HLA1V2-100VMs      | Full            | 5/14/2021 5:59 | 5/14/2021 9:52 | 3:53:01      | 1.65 TB                 | 493.56 GB/hr           | 528.78 GB        | 68                     | 3:25:51           |
| otherVMsizes-10VMs | Full            | 5/14/2021 5:59 | 5/14/2021 7:24 | 1:24:54      | 322.37 GB               | 264.18 GB/hr           | 91.14 GB         | 71                     | 1:13:13           |

### Scenario3:  Same stamp to External SMB storage

VMs in Stamp A

Proxy and Media agent in Stamp A

#### Storage Library on External SMB volume

| **VM Group**       | **Backup Type** | **Start Time** | **End Time**   | **Duration** | **Size of Application** | **Average Throughput** | **Data Written** | **Savings Percentage** | **Transfer Time** |
|--------------------|-----------------|----------------|----------------|--------------|-------------------------|------------------------|------------------|------------------------|-------------------|
| otherVMsizes-10VMs | Full            | 5/16/2021 3:58 | 5/16/2021 5:21 | 1:22:29      | 322.44 GB               | 247.71 GB/hr           | 77.2 GB          | 76                     | 1:18:06           |
| HLF4S-100VMs       | Full            | 5/16/2021 3:58 | 5/16/2021 5:22 | 1:24:08      | 296.55 GB               | 351.76 GB/hr           | 39.5 GB          | 86                     | 0:50:35           |
| HLF2SV2            | Full            | 5/16/2021 3:58 | 5/16/2021 7:03 | 3:05:19      | 1.34 TB                 | 466.15 GB/hr           | 501.21 GB        | 63                     | 2:56:04           |
| HLD3V2-20          | Full            | 5/16/2021 3:58 | 5/16/2021 6:17 | 2:18:35      | 650.01 GB               | 299.78 GB/hr           | 120.26 GB        | 81                     | 2:10:06           |
| HLA1V2-100VMs      | Full            | 5/16/2021 3:58 | 5/16/2021 7:53 | 3:55:24      | 1.65 TB                 | 505.65 GB/hr           | 351.97 GB        | 79                     | 3:21:03           |

#### Restore jobs Within Stamp

| Number of VMs restored | Throughput   | Size of App | Start Time      | End Time        |
|------------------------|--------------|-------------|-----------------|-----------------|
| 100                    | 396.37 GB/Hr | 270.96 GB   | 5/13/2021 23:27 | 5/14/2021 0:08  |
| 100                    | 821.78 GB/Hr | 1.65 TB     | 5/13/2021 23:25 | 5/14/2021 1:28  |
| 10                     | 288.04 GB/Hr | 322.36 GB   | 5/13/2021 15:45 | 5/13/2021 16:52 |
| 20                     | 477.53 GB/Hr | 1.23 TB     | 5/13/2021 15:43 | 5/13/2021 18:21 |
| 20                     | 358.97 GB/Hr | 650.04 GB   | 5/13/2021 15:38 | 5/13/2021 17:27 |

#### Restore jobs when library is configured on external SMB Storage

| Number of VMs restored | Throughput   | Size of App | Start Time      | End Time        |
|------------------------|--------------|-------------|-----------------|-----------------|
| 10                     | 322.43 GB/Hr | 322.43 GB   | 5/16/2021 1:06  | 5/16/2021 2:10  |
| 20                     | 781.37 GB/Hr | 1.33 TB     | 5/15/2021 22:32 | 5/16/2021 0:17  |
| 20                     | 367.88 GB/Hr | 650.12 GB   | 5/15/2021 20:38 | 5/15/2021 22:24 |
| 100                    | 539.91 GB/Hr | 292.6 GB    | 5/15/2021 20:01 | 5/15/2021 20:34 |
| 100                    | 589.19 GB/Hr | 1.65 TB     | 5/15/2021 16:57 | 5/15/2021 19:49 |

#### Change Block Tracking results using incremental Snapshots

| VM groups          | Backup Type | Start Time      | End Time        | Time Taken |
|--------------------|-------------|-----------------|-----------------|------------|
| otherVMsizes-10VMs | Full        | 5/14/2021 15:04 | 5/14/2021 16:36 | 1:31:48    |
| HLF4S-100VMs       | Full        | 5/14/2021 15:04 | 5/14/2021 16:16 | 1:11:22    |
| HLF2SV2            | Full        | 5/14/2021 15:04 | 5/14/2021 18:22 | 3:17:33    |
| HLD3V2-20          | Full        | 5/14/2021 15:04 | 5/14/2021 17:29 | 2:25:00    |
| HLA1V2-100VMs      | Full        | 5/14/2021 15:04 | 5/14/2021 19:12 | 4:07:39    |
| otherVMsizes-10VMs | Incremental | 5/14/2021 19:31 | 5/14/2021 20:28 | 0:56:56    |
| HLF4S-100VMs       | Incremental | 5/14/2021 19:31 | 5/14/2021 20:23 | 0:51:14    |
| HLF2SV2            | Incremental | 5/14/2021 19:31 | 5/14/2021 20:50 | 1:19:07    |
| HLD3V2-20          | Incremental | 5/14/2021 19:31 | 5/14/2021 22:45 | 3:13:49    |
| HLA1V2-100VMs      | Incremental | 5/14/2021 19:31 | 5/14/2021 22:38 | 3:07:02    |

#### Non- CBT(CRC) Full and Incremental Backups

| VM groups          | Backup Type | Start Time     | End Time        | Time Taken |
|--------------------|-------------|----------------|-----------------|------------|
| HLF4S-100VMs       | Full        | 5/14/2021 6:00 | 5/14/2021 7:40  | 1:40:16    |
| HLF2SV2            | Full        | 5/14/2021 6:00 | 5/14/2021 9:28  | 3:28:12    |
| HLD3V2-20          | Full        | 5/14/2021 5:59 | 5/14/2021 8:35  | 2:35:22    |
| HLA1V2-100VMs      | Full        | 5/14/2021 5:59 | 5/14/2021 9:52  | 3:53:01    |
| otherVMsizes-10VMs | Full        | 5/14/2021 5:59 | 5/14/2021 7:24  | 1:24:54    |
| HLF4S-100VMs       | Incremental | 5/14/2021 9:56 | 5/14/2021 11:43 | 1:47:21    |
| HLF2SV2            | Incremental | 5/14/2021 9:56 | 5/14/2021 13:19 | 3:23:31    |
| HLD3V2-20          | Incremental | 5/14/2021 9:55 | 5/14/2021 12:29 | 2:33:26    |
| HLA1V2-100VMs      | Incremental | 5/14/2021 9:55 | 5/14/2021 13:44 | 3:48:24    |
| otherVMsizes-10VMs | Incremental | 5/14/2021 9:55 | 5/14/2021 11:26 | 1:30:28    |
