# ecodms Document Management System on Synology NAS

## Why did I choose ecodms
My requirements were the following:
- My input documents are electronic PDFs and real paper that is scanned and saved to a folder
- I wanted a input folder where I can put the electronically available PDF documents and the scanned paper documents and afterwards these are processed automatically with minimal manual effort 
- Scanned PDFs get OCR'ed to PDF/A automatically (for fulltext index)
- Fulltext search on the context
- I was looking for an affordable system, since I only use it for a private purpose

The key features of ecodms I coudld not find in any other open source or affordable document management system were the possibility to automate the process of classification of the document based on keyword searches and automatic extraction of a certain text from the document with the help of regular expressions.


## Installation

## REGEX functions I am using

### Identify everything after a certain word
#### Example 1: "Kontoauszug Nummer 001 / 2011 vom 01.01.2011 bis 05.01.2011"

To identify everythin after the word "Kontoauszug", until the date field in the format "dd.mm.yyyy", e.g.
```
Kontoauszug Nummer 001 / 2011 vom 01.01.2011 bis 05.01.2011
```
I used the following REGEX,

```
REGEX:(?i)\b(?<=Kontoauszug).*\d{2}\.\d{2}\.\d{4}\b
```

which results in:
```
Nummer 001 / 2011 vom 01.01.2011 bis 05.01.2011
```

#### Example 2: "Abrechnung:         Januar 2011"

To identify everythin after the word "Abrechnung", until the date field in the format "yyyy", e.g.
```
Abrechnung:         Januar 2011
```
I used the following REGEX,

```
REGEX:(?i)(?<=Abrechnung)[\s|:]+\b.*\d{4}\b
```
which results in:
```
: Januar 2015
```
Unfortunately I did not find a way to eliminate the ":" in the result. Any hint is apreciated.


## create scheduled task for backup
If the docker service ist started on the Synology disk station it does not switch to standby any more and therefore I only start it on purpose, if I need to archive documents or search for documents.

But I wanted to have a regular daily backup of all data, therefore I created the [ecodms/backup.sh](backup.sh) and set up a scheduled task that runs once a day. See https://www.synology.com/en-global/knowledgebase/DSM/help/DSM/AdminCenter/system_taskscheduler for details on setting up a scheduled task on synology.
Make sure you enter add the shell interpreter (/bin/sh ) before the full path name to the script:

```
/bin/sh /volume1/the_path_you_have_saved_the_script_on_your_synology/backup.sh
```
