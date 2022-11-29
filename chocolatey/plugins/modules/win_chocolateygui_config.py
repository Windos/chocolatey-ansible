#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2018, Ansible Project
# Copyright: (c) 2020, Chocolatey Software
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = r'''
---
module: win_chocolateygui_config
version_added: '1.4.0'
short_description: Manages Chocolatey GUI config settings
description:
- Used to manage Chocolatey GUI config settings as well as unset the values.
options:
  name:
    description:
    - The name of the config setting to manage.
    - See U(https://docs.chocolatey.org/en-us/chocolatey-gui/setup/configuration/settings/) for a list of
      valid configuration settings that can be changed.
    - Any config values that contain encrypted values like a password are not
      idempotent as the plaintext value cannot be read.
    type: str
    required: yes
  state:
    description:
    - When C(absent), it will ensure the setting is unset or blank.
    - When C(present), it will ensure the setting is set to the value of
      I(value).
    type: str
    choices: [ absent, present ]
    default: present
  value:
    description:
    - Used when C(state=present) that contains the value to set for the config
      setting.
    - Cannot be null or an empty string, use C(state=absent) to unset a config
      value instead.
    type: str
seealso:
- module: win_chocolatey
- module: win_chocolateygui_feature
- module: win_chocolatey_facts
- module: win_chocolatey_feature
- module: win_chocolatey_source
author:
- Jordan Borean (@jborean93)
- Josh King (@WindosNZ)
'''

EXAMPLES = r'''
- name: Set default source name
  win_chocolatey_config:
    name: DefaultSourceName
    state: present
    value: ChocoInternal

- name: Unset default source name
  win_chocolatey_config:
    name: DefaultSourceName
    state: absent
'''

RETURN = r'''
'''
