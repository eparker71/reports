#!/bin/bash

# project = "TLT" and issuetype in (Story, Bug, spike, "Technical Debt", Release) and
# status in (Resolved)  and updated < now() and updated > '2018/01/06'

# project = "ATG Unattached"  and issuetype in (Epic)

DATA_FILE=$1
EPIC_FILE=$2

sqlite3 test_db "drop table epic_tbl;"
sqlite3 test_db "drop table data_tbl;"

F1=$(python find_column.py "Custom field (Story Points)")

cut -d'|' -f1,4,6,7 $DATA_FILE | grep -v Subtask | grep -v Release | sed -e 's/|/,/g' > clean_data.csv
sed -i -e 's/Custom field (Story Points)/StoryPoints/g' clean_data.csv
sed -i -e 's/Custom field (Epic Link)/EpicLink/g' clean_data.csv
sed -i -e 's/Issue Type/IssueType/g' clean_data.csv

cut -d'|' -f2,14 $EPIC_FILE > clean_epics.csv
sed -i -e 's/Issue key/Issuekey/g' clean_epics.csv
sed -i -e 's/Custom field (Epic Name)/EpicName/g' clean_epics.csv

csvsql --db sqlite:///test_db --tables epic_tbl --insert clean_epics.csv
csvsql --db sqlite:///test_db --tables data_tbl --insert clean_data.csv

sqlite3 -echo test_db "update data_tbl set EpicLink = '1' where Summary like '%buffer%';"
sqlite3 -echo test_db "insert into epic_tbl values ('1','Buffer');"

sqlite3 -echo test_db "update data_tbl set EpicLink = '0' where EpicLink is null;"
sqlite3 -echo test_db "insert into epic_tbl values ('0','No Epic');"

echo "Epics, Total" > report_data.csv
sqlite3 test_db 'select EpicName,sum(StoryPoints) from data_tbl d, epic_tbl e where e.Issuekey = d.EpicLink and EpicLink not null group by EpicName;' | sed -e 's/|/,/g' >> epic_report.csv

echo "IssueType, Total" > issuetype_report.csv
sqlite3 test_db 'select IssueType, sum(StoryPoints) from data_tbl group by IssueType;' | sed -e 's/|/,/g' >> issuetype_report.csv

rm -f clean_*
