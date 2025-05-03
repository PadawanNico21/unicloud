import subprocess


class ShellCmd(object):
    output = {}
    child = []
    rc = 0
    pid = 0

    def __init__(self, cmd):
        self.cmd = cmd
        out = subprocess.Popen(
            [cmd], shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT
        )
        stdout, _ = out.communicate()
        self.output = stdout.decode(errors="replace")[:-1]
        self.rc = out.returncode
        self.pid = out.pid

    def __repr__(self):
        return self.output

    def getrc(self):
        return self.rc

    def getpid(self):
        return self.pid
