Lightweight Docker images for [ZMK][zmk].

### Platforms

#### Tested
- `arm` (`amd64`)

#### Not Tested
- `arc` (`amd64`, `arm64`)
- `arm` (`arm64`)
- `arm64` (`amd64`, `arm64`)
- `mips` (`amd64`, `arm64`)
- `nios2` (`amd64`, `arm64`)
- `riscv64` (`amd64`, `arm64`)
- `sparc` (`amd64`, `arm64`)
- `x86_64` (`amd64`, `arm64`)
- `xtensa_intel_apl_adsp` (`amd64`, `arm64`)
- `xtensa_intel_bdw_adsp` (`amd64`, `arm64`)
- `xtensa_intel_byt_adsp` (`amd64`, `arm64`)
- `xtensa_intel_s1000` (`amd64`, `arm64`)
- `xtensa_nxp_imx8m_adsp` (`amd64`, `arm64`)
- `xtensa_nxp_imx_adsp` (`amd64`, `arm64`)
- `xtensa_sample_controller` (`amd64`, `arm64`)

### Images

#### build

For _building_ [ZMK][zmk] firmware with CI.

- FROM: **[ubuntu][ubuntu]**
- Includes:
  - essential [Zephyr][zephyr] dependencies (`apt-get`)
    - non-build dependencies are _not_ included. e.g. `pip3`, UI packages, etc.
  - base [Zephyr][zephyr] Python requirements
  - platform's [Zephyr][zephyr] toolchain

#### dev

For _developing_ [ZMK][zmk] (firmware and documentation).

- FROM: **build**
- Includes:
  - remaining [Zephyr][zephyr] dependencies (`apt-get`)
  - build and test [Zephyr][zephyr] Python requirements
  - other useful development packages

[ubuntu]: https://hub.docker.com/_/ubuntu "Ubuntu"
[zephyr]: https://github.com/zephyrproject-rtos/zephyr "Zephyr"
[zmk]: https://github.com/zmkfirmware/zmk "ZMK"
