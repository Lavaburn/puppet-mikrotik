# Memory

> Chronological action log. Hooks and AI append to this file automatically.
> Old sessions are consolidated by the daemon weekly.

| 07:29 | Fixed suitable? feature cache clearing: @values → @results (wrong ivar, bug was silently no-op) | lib/puppet/provider/mikrotik_api.rb | fixed | ~80 tok |

| 11:39 | Fixed multi-device feature cache bug | lib/puppet/provider/mikrotik_api.rb | added suitable? override that clears ros_v6/v7 feature cache on transport change | ~800 |
| 2026-05-07 | Fixed @defaultprovider cache bug (bug-002): also reset type-level @defaultprovider on device change via Puppet::Type.eachtype | lib/puppet/provider/mikrotik_api.rb | fixed | ~900 |
| 2026-09-16 | Added ROS 7.20 BGP instance support + afi rename; fixed instance always-absent (bug-003) | lib/puppet/{type,provider}/mikrotik_v7_bgp_*, feature/ros_v7_20.rb | committed ea9824e, 51286d3 | ~3000 |
| 2026-10-29 | Added mikrotik_radius_incoming (singleton, vrf warns+ignored on v6) | lib/puppet/{type,provider}/mikrotik_radius_incoming*, spec/acceptance/radius_spec.rb | uncommitted | ~1500 |
| 2026-10-29 | Added mikrotik_ip_hotspot_walled_garden + _ip (comment title, ensurable, dynamic skipped) | lib/puppet/{type,provider}/mikrotik_ip_hotspot_walled_garden*, spec/acceptance/ip_hotspot_spec.rb | uncommitted | ~3000 |
