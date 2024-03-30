# %% Imports
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import signal
from matplotlib.ticker import EngFormatter

# %% Analytics
# Data for plotting
fs = 48000
Ts = 1/fs
f = 1000
t_end = 1/f
t = np.arange(0.0, t_end, Ts)
s = np.sin(2 * np.pi * f * t)

fig, ax = plt.subplots(figsize=(12, 6))
ax.plot(t, s)
ax.set(xlabel='time [s]', ylabel='amplitude [V]', title='Waveform')
ax.xaxis.set_major_formatter(EngFormatter(unit='s'))
ax.grid(linewidth=1, color='lightgray', alpha=0.5)
ax.grid(which='minor', linestyle=':', linewidth=1, color='lightgray', alpha=0.25)
# ax.axhline(y=0.0, color='black', linestyle='-', linewidth=0.85, zorder=0)

#plt.savefig(f"{os.path.dirname(__file__)}/pdm_sine.png", dpi=512, bbox_inches='tight')
plt.savefig(f"{os.path.dirname(__file__)}/pdm_sine.pdf", bbox_inches='tight')
plt.show()

# %%
