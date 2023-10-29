#!/bin/python3

#read yml file from /config.yml

import yaml
import os


# def get_cmds():
#     cmds = []
#     with open(os.path.expanduser('~/pid.out'), 'r') as pid_file:
#         pids = pid_file.read().splitlines()

#     for pid in pids:
#         with open(f'/proc/{pid}/stat', 'r') as stat_file:
#             cmd = stat_file.read().split()[1].strip('()')
#         print(cmd)
#         cmds.append(cmd)

#     return cmds

def rewrite_config(cmd):
    with open(os.path.expanduser('~/config.yml'), 'r') as config_file:
        config = yaml.safe_load(config_file)
        print(config)


if __name__ == '__main__':
    rewrite_config('test')
    # get_cmds()
        
