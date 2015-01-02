CheckValve Chat Relay
=====================

The CheckValve Chat Relay allows client devices such as mobile phones to receive
chat messages from HLDS/SRCDS servers.  It is a cross-platform program developed
in Java, which basically does three things:

1. Listens for connection requests from client devices
2. Listens for log messages coming from HLDS/SRCDS servers
3. Parses the log messages and sends chat messages to clients

Change Log
----------
**Version 1.0.0**
- Initial release.

**Version 1.1.0**
- Fixed handling of SRCDS and HLDS console chat messages.
- Fixed incorrect content length in packets.
- Added command line option to specify the configuration file.
- Added `usage()` method to show command line options.
- Added `debugLevel` option for more verbose logging.
- Added code for additional logging based on the value of `debugLevel`.

**Version 1.2.0**
- Added support for the new SteamID format.
- Fixed some default option values not matching the defaults listed in the checkvalvechatrelay.properties file.

**Version 1.2.1**
- Added warnings if the client or message listener is using a loopback address.

