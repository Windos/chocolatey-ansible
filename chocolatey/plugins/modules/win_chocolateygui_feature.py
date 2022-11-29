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
module: win_chocolateygui_feature
version_added: '1.4.0'
short_description: Manages Chocolatey GUI features
description:
- Used to enable or disable features in Chocolatey GUI.
options:
  name:
    description:
    - The name of the feature to manage.
    - Run C(chocolateyguicli.exe feature list) to get a list of features that can be
      managed.
    - For a list of options see L(Chocolatey feature docs, https://docs.chocolatey.org/en-us/chocolatey-gui/user-interface/settings/chocolatey-gui#features)
    type: str
    required: yes
  state:
    description:
    - When C(disabled) then the feature will be disabled.
    - When C(enabled) then the feature will be enabled.
    type: str
    choices: [ disabled, enabled ]
    default: enabled
seealso:
- module: win_chocolatey
- module: win_chocolateygui_config
- module: win_chocolatey_config
- module: win_chocolatey_facts
- module: win_chocolatey_source
author:
- Jordan Borean (@jborean93)
- Josh King (@WindosNZ)
'''

EXAMPLES = r'''
- name: Enable hiding the This PC source
  win_chocolateygui_feature:
    name: HideThisPCSource
    state: enabled

- name: Disable using keyboard bindings
  win_chocolateygui_feature:
    name: UseKeyboardBindings
    state: disable
'''

RETURN = r'''
'''
