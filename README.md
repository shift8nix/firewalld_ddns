Bash script that maintaines source ip based on domain name in firewalld. 


install bind-utils first
```
yum -y install bind-utils
```

Scrip is called followed by domain name. By default "trusted" firewall zone is selected:
```
./update_trusted_source.sh example.com
```
But you can specify any other zone. Here I choosed public zone.
```
./update_trusted_source.sh example.com public
```
Set up cron job to run it specific intervals, like 5 min. or so.

How about adding more than one source? 

Use wrapper around this script.

Use file "domains" and append them one per line.

Then run it with:
```
./update_trusted_source_wrapper.sh
```
you can specify zone other than "trusted" as well:
```
./update_trusted_source_wrapper.sh public
```
