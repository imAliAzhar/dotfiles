import i3  # pip install i3-py

num = i3.filter(i3.get_workspaces(), focused=True)[0]['num']
ws_nodes = i3.filter(num=num)[0]['nodes']
ws_nodes = ws_nodes + i3.filter(num=num)[0]['floating_nodes']
curr = i3.filter(ws_nodes, focused=True)[0]

ids = [win['id'] for win in i3.filter(ws_nodes, nodes=[])]

next_idx = (ids.index(curr['id']) - 1) % len(ids)
next_id = ids[next_idx]

i3.focus(con_id=next_id)
