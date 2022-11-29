from __future__ import (absolute_import, division, print_function)
__metaclass__ = type


def choco_localtileview_state(value):
    return [i for i in value if i.startswith("DefaultToTileViewForLocalSource|")][0].split("|")[1] == "Enabled"


class FilterModule(object):

    def filters(self):
        return {
            'choco_localtileview_state': choco_localtileview_state
        }
