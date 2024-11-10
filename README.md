# swift-pcsc

Swift wrapper around pcsc-lite

## Supported Platfroms:

- macOS
- Linux (Ubuntu 24.04)

## Installation

```swift
.package(
    url: "https://github.com/unistash-io/swift-pcsc.git",
    .upToNextMajor(from: "0.0.1")
)
```

### MacOS

- No additional steps required

### Linux (Ubuntu 24.04)

```
sudo apt update
sudo apt install -y pkg-config pcscd pcsc-tools libpcsclite1 libpcsclite-dev
```

## Authors

- adam@stragner.com
