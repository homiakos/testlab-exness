import site 
import ldap3
import json
import re
from ansible.plugins.action import ActionBase

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()

class ActionModule(ActionBase):

    def run(self, tmp=None, task_vars=None):

        if task_vars is None:
            task_vars = dict()
        result = super(ActionModule, self).run(tmp, task_vars)

        group_name = self._task.args.get('name', None)
        if group_name is None:
            result['msg'] = "Group 'name' is required"
            return result
        state = self._task.args.get('state', 'present')
        display_name = self._task.args.get('name', group_name)

        domain_server = self._task.args.get('domain_server', None)
        if domain_server is None:
            result['msg'] = "'domain_server' is required"
            return result
        domain_password = self._task.args.get('domain_password', None)
        if domain_password is None:
            result['msg'] = "'domain_password' is required"
            return result
        domain_username = self._task.args.get('domain_username', None)
        if domain_username is None:
            result['msg'] = "'domain_username' is required"
            return result

        description = self._task.args.get('description', None)
        if description is None:
            result['msg'] = "'description' is required"
            return result
        organizational_unit = self._task.args.get('organizational_unit', None)
        if organizational_unit is None:
            result['msg'] = "'organizational_unit' is required"
            return result

        server = ldap3.Server(domain_server, port=636, use_ssl=True,
                         get_info='ALL')
        # define the connection
        ldap = ldap3.Connection(server, user=domain_username, password=domain_password)
        # perform the Bind operation
        if not ldap.bind():
            display.vvvv('error in bind', ldap.result)
            exit(1)

        ldap.search(organizational_unit, "(&(objectclass=Group)(cn=%s))" % group_name)
        if len(ldap.entries) == 0 and state == 'present':
            display.vvvv("Creating group %s" % group_name)
            ldap.add(
                "cn=%s,%s" % (group_name, organizational_unit),
                'Group',
                {
                    'description': description,
                    'sAMAccountName': group_name,
                    'displayName': display_name
                }
            )
            display.vvvv(ldap.result)
            result = ldap.result
            result['changed'] = True
        else:
            return result
        return result
