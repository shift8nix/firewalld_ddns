#! /bin/bash
cd $(dirname $0)

# Using positional vars $1 domain name $2 zone
dyn_name="$1"
# defaults to trusted zone
if [[ $2 = "" ]];
 then
  zone="trusted"
 else
  zone="$2"
fi

# newip - use first record returned by dig if multiple
newip=$(/usr/bin/dig $dyn_name +short | head -1)


# Check response from dig - must not be empty (not resolved / no connection) 
function fn_dig_check ()
if [[ $newip == "" ]];
 then
  logger update_trusted_source.sh:error:domain not resolved domain=$dyn_name zone=$zone
  exit 2
fi

# check if new ip present in firewall. If present in desired zone - exit.
# If present in different zone - exit with error
function fn_in_firewall ()
{
if [[ $(firewall-cmd --get-active-zones) =~ $newip ]];
 then
  if [[ ! $(firewall-cmd --list-sources --zone=$zone) =~ $newip ]];
   then
    logger update_trusted_source.sh:error:source conflict domain=$dyn_name zone=$zone ip=$newip
    exit 2
   else 
    exit
  fi
fi
}

# check if old ip in firewall. Update firewall
function fn_update ()
{
oldip=$(/bin/cat ./ip_of_$dyn_name 2>/dev/null)
if [[ $(firewall-cmd --list-sources --zone=$zone) =~ $oldip ]] && [[ ! $oldip == "" ]];
 then
  firewall-cmd --remove-source=$oldip --zone=$zone
  logger update_trusted_source.sh:info:rule changed ip removed domain=$dyn_name zone=$zone oldip=$oldip
  fn_update_action
 else
  fn_update_action
fi
}

# for compact code
function fn_update_action ()
{
  firewall-cmd --add-source=$newip --zone=$zone
  echo $newip > ./ip_of_$dyn_name
  logger update_trusted_source.sh:info:rule changed ip added domain=$dyn_name zone=$zone newip=$newip
}

fn_dig_check
fn_in_firewall
fn_update
exit
