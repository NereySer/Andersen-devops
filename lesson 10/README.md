# About script
The script is used to display information about EBS snapshots: ID, size and StartTime. Snapshots are filtered by StartTime and output older or younger than specified time. Parameters to run:
- Key -n is used to set how many time counts takes away from the current time. Optional, default is 1.
- Keys -d, -h, -m, -s is used to set time multiplier to Days, Hours, Minutes and Seconds for the key -n. Optional, default is days.
- Key -i is used to invert selection to younger. If not specified, selection of older.
- Key -t is used to switch output to table. If not specified, output in json format.
- Key -o is used to specify owner ID (or IDs as in the --owner-ids option of the aws ec2 describe-snapshots command). Optional, default is self.

Tip: to get all the snapshots, use -n 0.

# TIL
Today I've learned about command line cloud management tools (awscli, azcli) and Terraform cycles and conditional expressions.

_17.12.2021_
