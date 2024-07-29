import requests
import json


#Modify these values to match your environment
nd_cluster=""
nd_auth_domain="local"
nd_user=""
nd_pwd=""
fabric_name=""
##

def get_token():  
   url = nd_cluster+"/login"
   payload = {
        "domain": nd_auth_domain,
        "userName": nd_user,
        "userPasswd": nd_pwd
   }
   headers = {
      "Content-Type" : "application/json"
   }
   requests.packages.urllib3.disable_warnings()
   response = requests.post(url,data=json.dumps(payload), headers=headers, verify=False).json()
   token = response['token']
   return token
   
def get_switches(auth_token): 
   url = nd_cluster+"/appcenter/cisco/ndfc/api/v1/lan-fabric/rest/control/fabrics/"+fabric_name+"/inventory/switchesByFabric"
   headers = {
      "Content-Type" : "application/json",
      "Cookie" : "AuthCookie="+auth_token
   }
   return requests.get(url,headers=headers, verify=False).json()

def get_intf_policies(auth_token,sn,template_name): 
   url = nd_cluster+"/appcenter/cisco/ndfc/api/v1/lan-fabric/rest/interface?templateName="+template_name+"&serialNumber="+sn
   headers = {
      "Content-Type" : "application/json",
      "Cookie" : "AuthCookie="+auth_token
   }
   return requests.get(url,headers=headers, verify=False).json()

def update_intf_policies(auth_token,policy_id): 
   #First need to retrieve the policy with its content
   url = nd_cluster+"/appcenter/cisco/ndfc/api/v1/lan-fabric/rest/control/policies/"+policy_id
   headers = {
      "Content-Type" : "application/json",
      "Cookie" : "AuthCookie="+auth_token,
   }
   policy_content=requests.get(url,headers=headers, verify=False).json()
   #Once the policy info is retrieved, we need to modify the specific CLI field
   if "ttag-strip" in policy_content['nvPairs']['CONF']:
     policy_content['nvPairs']['CONF']=policy_content['nvPairs']['CONF'].replace('ttag-strip', '')
   if "ttag" in policy_content['nvPairs']['CONF']:
     policy_content['nvPairs']['CONF']=policy_content['nvPairs']['CONF'].replace('ttag', '')
   policy_content['nvPairs']['CONF']=policy_content['nvPairs']['CONF'].replace('\n\n', '') 
   #Once the policy is modified, we need to put the new content.
   return requests.put(url,headers=headers, verify=False,data=json.dumps(policy_content))
   

# Store switches in a python dictionary.
switches_dict=get_switches(get_token())
# Convert dictionary to a list
sn_list=[]
for A in switches_dict:
    #print (A['serialNumber'])
    sn_list.append(A['serialNumber'])

intf_policy_ids=[]
# First "int_trunk_host" policies
for A in sn_list:
   int_trunk_list=[]
   int_trunk_dict=get_intf_policies(get_token(),A,"int_trunk_host")
   if (int_trunk_dict):
    int_trunk_list=int_trunk_dict[0]['interfaces']
   for B in int_trunk_list:
      if "ttag" in B['nvPairs']['CONF']:
         intf_policy_ids.append(B['nvPairs']['POLICY_ID'])
      int_trunk_list=[]
      int_trunk_dict={}

# Second "int_access_host" policies
for A in sn_list:
   int_access_list=[]
   int_access_dict=get_intf_policies(get_token(),A,"int_access_host")
   if (int_access_dict):
      int_access_list=int_access_dict[0]['interfaces']
   for B in int_access_list:
      if "ttag" in B['nvPairs']['CONF']:
         intf_policy_ids.append(B['nvPairs']['POLICY_ID'])
      int_access_list=[]
      int_access_dict={}



# Now we can modify the policies

for policy_id in intf_policy_ids:
   result=update_intf_policies(get_token(),policy_id)
   if "200" in str(result):
    print (str(result)+"Policy: "+policy_id+" modified correctly")
   else:
    print (str(result)+"Policy: "+policy_id+" modification failed!")
