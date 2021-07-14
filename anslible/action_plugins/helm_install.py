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

        chart = self._task.args.get('chart', None)
        if chart is None:
            result['msg'] = "'chart' is required"
            return result

        source = self._task.args.get('source', None)
        if source is None:
            source = 'stable/%s' % chart

        release = self._task.args.get('release', None)
        if release is None:
            release = chart

        version = self._task.args.get('version', None)
        namespace = self._task.args.get('namespace', 'kube-system')
        additional_set = self._task.args.get('additional_set', [])
        kubeconfig_path = self._task.args.get('kubeconfig_path', None)

        charts = dict()
        cmd = '%shelm list' % (
            kubeconfig_path and 'KUBECONFIG=%s ' % kubeconfig_path or '')
        helm_list_res = self._low_level_execute_command(cmd)
        if helm_list_res['rc'] != 0:
            result['failed'] = True
            result['msg'] = helm_list_res.get(
                'stderr', 'Missing helm command or wrong version')
            return result

        for line in helm_list_res.get('stdout', '').splitlines():
            if line.startswith('NAME'): continue
            parts = [p.strip() for p in line.split('\t')]
            charts.update({parts[0]: dict(
                status=parts[3], fullname=parts[4], ns=parts[5])})

        display.vvvv("Found charts: %s" % charts)

        needs_upgrade = False
        if release in charts:
            actual_chart = charts.get(release)
            if actual_chart['status'] == 'DEPLOYED':
                needs_upgrade = True
            if version is None:
                result['changed'] = False
                return result
            if version is not None:
                if re.match(r'^%s-%s$' % (chart, version),
                            actual_chart['fullname']) is not None:
                    if actual_chart['status'] == 'DEPLOYED':
                        result['changed'] = False
                        return result

        set_flags = ' '.join([
            '--set %s' % flag for flag in additional_set
        ])
        pre0 = '%shelm init --client-only >/dev/null 2>&1' % (
            kubeconfig_path and 'KUBECONFIG=%s ' % kubeconfig_path or '')
        pre1 = '%shelm repo update >/dev/null 2>&1' % (
            kubeconfig_path and 'KUBECONFIG=%s ' % kubeconfig_path or '')
        if needs_upgrade:
            cmd = '%s && %s && %shelm upgrade -i%s%s%s --namespace %s --wait %s %s' % (
                pre0, pre1,
                (kubeconfig_path and 'KUBECONFIG=%s ' % kubeconfig_path or ''),
                (self._play_context.check_mode and ' --dry-run' or ''),
                (version is not None and ' --version %s' % version or ''),
                (set_flags and ' %s' % set_flags or ''),
                namespace, release, source)
        else:
            cmd = '%s && %s && %shelm install%s%s%s --namespace %s --name %s --wait %s' % (
                pre0, pre1,
                (kubeconfig_path and 'KUBECONFIG=%s ' % kubeconfig_path or ''),
                (self._play_context.check_mode and ' --dry-run' or ''),
                (version is not None and ' --version %s' % version or ''),
                (set_flags and ' %s' % set_flags or ''),
                namespace, release, source)


        display.vvvv("Executing: %s" % cmd)

        res = self._low_level_execute_command(cmd)
        failed = res['rc'] > 0
        result['failed'] = failed
        result['msg'] = res['stdout'].splitlines()
        return result
