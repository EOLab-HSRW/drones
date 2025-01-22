# Development

## Repositories

| Repo                                                           | Description                                                    |
|----------------------------------------------------------------|----------------------------------------------------------------|
| [`eolab_px4`](https://github.com/EOLab-HSRW/eolab_px4)         | our utility tool to create, custimize and launch px4 firmware. |
| [`fw-components`](https://github.com/EOLab-HSRW/fw-components) | set of common "firmware components" configuration files.       |
| [`fw-template`](https://github.com/EOLab-HSRW/fw-template)     | template for structure of firmware configuration files.        |
| [`fw-phoenix`](https://github.com/EOLab-HSRW/fw-phoenix)       | firmware parameters.                                           |
| [`fw-platypus`](https://github.com/EOLab-HSRW/fw-platypus)     | firmware parameters.                                           |
| [`fw-sar`](https://github.com/EOLab-HSRW/fw-sar)               | firmware parameter.                                            |

## `eolab_px4`

TBA

## `fw-template`

> Note: this is the same rational for any repo with the naming format: `fw-<drone name>`.

template structure to track firmware configuration for our drones. Each drone has its own repository (e.g. `fw-phoenix`), this allows us to version the drone parameters and modules into the drone firmware, so it make it easy to roll-back to previous version of the parameters.

Structure:
```
fw-template/
├─ airframe (mandatory)
├─ modules (mandatory)
├─ version (mandatory)
```

## `fw-components`

Contains set of parameters of what we call `fw-component` (firmware component). A `fw-component` is just a folder with a file containing firmware parameters, for example for a given radio controller, or a given payload, camera, gymbal, etc. The idea behind this repository is that there is a common place to put the necessary parameters to add any components to our drone catalog.

The idea behind these files is that we can perform composite aggregation of these parameters in any of our drone firmwares, by selecting the “fw-components” that we want to include in the firmware.

Structure:
```
fw-components/
├─ radiomaster_tx16s/
│  ├─ params
│  ├─ modules (optional)
├─ component_2/
│  ├─ params
├─ component_n/
├─ params
├─ modules (optional)
```

versioning: TBA....
