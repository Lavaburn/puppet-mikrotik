# Cerebrum

> OpenWolf's learning memory. Updated automatically as the AI learns from interactions.
> Do not edit manually unless correcting an error.
> Last updated: 2026-04-13

## User Preferences

<!-- How the user likes things done. Code style, tools, patterns, communication. -->

## Key Learnings

- **Project:** puppet-mikrotik
- **Description:** Puppet Module for managing Mikrotik Devices
- **Feature caching in multi-device runs:** `Puppet.features.add(:ros_v7)` blocks are cached globally after first evaluation. In `puppet device` without `--target`, all devices share one Ruby process, so the first device to trigger ros_v7 evaluation sets the cached value for ALL subsequent devices. This breaks v7 provider selection when v6 devices appear before v7 devices in device.conf. Fixed in `mikrotik_api.rb` via `suitable?` override that clears the feature cache on transport change.
- **`Puppet::Util::Feature` cache ivar is `@results`, not `@values`:** Both Puppet 6 and 7 use `@results` as the internal hash caching feature block results. When clearing the feature cache via `instance_variable_get`, always use `:@results`. Using `:@values` silently returns nil and the clearing block never executes.
- **Shared types trigger cross-device feature evaluation:** Types with both v6 and v7 providers (e.g., `mikrotik_mpls_ldp_instance`) cause Puppet to evaluate BOTH provider confines (including `ros_v7`) for every device that uses that type — not just v7 devices. This is the mechanism that causes the cache pollution.
- **`@_last_transport_id` is stored on the base class:** Using `Puppet::Provider::Mikrotik_Api.instance_variable_get/set` ensures the transport tracking is shared across all subclass `suitable?` calls, so the feature cache is cleared exactly once per device transition.
- **Provider cache clearing must happen BEFORE provider assignment, not in suitable?:** Puppet assigns providers to all resources upfront via `type.defaultprovider`. If `@defaultprovider` is stale, it is returned without calling `suitable?`. By the time `suitable?` runs (in `prefetch_if_necessary`), resources are already committed to the wrong provider — Puppet 6 then fails them with "not functional" rather than re-assigning. Fix: clear `@defaultprovider` and feature cache in `Device#initialize` (`_reset_version_caches`), which runs before the transaction assigns providers. The `suitable?` override is kept as a secondary defence only.

## Do-Not-Repeat

<!-- Mistakes made and corrected. Each entry prevents the same mistake recurring. -->
<!-- Format: [YYYY-MM-DD] Description of what went wrong and what to do instead. -->

## Decision Log

<!-- Significant technical decisions with rationale. Why X was chosen over Y. -->
