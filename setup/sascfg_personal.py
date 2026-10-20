# saspy configuration for SAS OnDemand for Academics (ODA).
# Copy this file to:  ~/.config/saspy/sascfg_personal.py
#
# Check your ODA dashboard for your home region's server names and
# replace the 'iomhost' list below if yours are different.
#   US Home Region 1 (shown below):  odaws01-usw2.oda.sas.com ... odaws04-usw2.oda.sas.com
#   US Home Region 2:                odaws01-usw2-2.oda.sas.com ... odaws04-usw2-2.oda.sas.com

SAS_config_names = ['oda']

oda = {
    'java':     'java',   # or the full path to Java, e.g. '/usr/bin/java'
    'iomhost':  ['odaws01-usw2.oda.sas.com', 'odaws02-usw2.oda.sas.com',
                 'odaws03-usw2.oda.sas.com', 'odaws04-usw2.oda.sas.com'],
    'iomport':  8591,
    'authkey':  'oda',    # reads your login from ~/.authinfo (see README)
    'encoding': 'utf-8',
}
