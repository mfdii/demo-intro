constore Cookbook
=================
Convenience Store (constore) provides the ability to sync Roles, Environments, and Cookbooks between multiple Chef servers. It was written to demonstrate the concept and needs work to make it production. 


Requirements
------------
Requires specific Attributes to be set either via a role, environment, or directly on the node. 

First a role called `constore_base` needs to be created with the following attributes:

```json
  "default_attributes": {
    "constore" : {
      "repos" : {
        "repo1": {
          "name": "demo-intro",
          "url": "https://github.com/mfdii/demo-intro"
          }
        }
      }
  },
```
  
Second, for each server create a `constore_<servername>` role with the follow attributes.


```json  
"default_attributes": {
    "constore" : {
      "repos" : {
        "repo1":{
          "client_key": "demo-intro-server-1",
          "client_name": "chef",
          "org_name": "opscode"
        }
      }
    }
  },
  "run_list": [
    "recipe[constore]"
  ]
```

Lastly, a data bag with a client key the server can use to upload the artifacts should be created. The cookbook expects a data bag called `constore_clients`. The data bag items should look like so:

`
{
	"id": "demo-intro-server-1",
  "name": "demo-intro-server-1",
  "key":["-----BEGIN RSA PRIVATE KEY-----",
        "MIIEpAIBAAKCAQEAnF0oMjP+0bddWSyKmDE7I8KYWgIniEjCEg8EcaR+8MvP1ekc",
        "BNG++yRNqlIRbkyi8y/FYADpFXF+XPGSGb9MhbzdTgVJc4xDjL4LjEslTY3JKeJS",
        "5It4IqoS5iwxeNVVgib6jR6ZZwXBwy8Z/kz43U6LXavTTqOBTwPdo3ceeYNVtbY9",
        //key truncated for example purposes 
        "boru/QKBgQDK6vUfGQXZn92A3FMW1u/hNd1jsPzaDDynJYI7KEF4814VHyWxnecV",
        "dkXHjW4wqupHydXognHCi/xF1ZtQu6kdQV7dr1RJgcuhhPFP8qZ2ispxmOxDCyxB",
        "BNqsSjuvhPhevtGHlGaSa+FTkzGZbRFHEggILpN/LNXAXjVajFRDQA==",
        "-----END RSA PRIVATE KEY-----"]
}
`

  

Attributes
----------

#### constore::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['constore']['repo_dir']</tt></td>
    <td>String</td>
    <td>directory to store local copy of a repo</td>
    <td><tt>/var/chef/constore/tt></td>
  </tr>
</table>

Usage
-----
#### constore::default
Include the roles on the run_list of the nodes with Chef server installed. The server specific role should come after the base role.

The default recipe iterates over each repo defined in the `constore_base` role, grabs the server spefic key and client name, sync the git repo if needed, and then attempts to sync the repos

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Michael Ducy <michael@getchef.com>
