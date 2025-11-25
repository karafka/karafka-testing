# Karafka Testing Changelog

## 2.5.5 (Unreleased)
- [Feature] Add `produce_to` method for explicit consumer targeting in multi-consumer scenarios.
- [Fix] Fix consumer mapping collision when multiple consumer groups listen to the same topic.

## 2.5.4 (2025-10-03)
- [Fix] Topic present in second dynamically built subscription group not available for dispatch (#291).
- **[EOL]** Remove Ruby `3.1` according to the EOL schedule.

## 2.5.3 (2025-08-12)
- [Fix] Allow testing consumers with Pro expansions (i.e. Piping).

## 2.5.2 (2025-08-04)
- [Enhancement] Change RSpec hook execution order issue in Karafka testing helpers.
- [Change] Remove `funding_uri` from the gemspec to minimize double-funding info.
- [Change] Add new CI action to trigger auto-doc refresh.

## 2.5.1 (2025-05-25)
- [Change] Move to trusted-publishers and remove signing since no longer needed.

## 2.5.0 (2025-05-21)
- [Maintenance] Release matching Karafka `2.5.0` release.

## 2.4.7 (2025-04-01)
- **[EOL]** Drop Ruby `3.0` support according to the EOL schedule.
- **[Fix]** Check not only that `Mocha` is loaded but also that its stubs are used.

## 2.4.6 (2024-07-31)
- [Fix] uninitialized constant `Karafka::Testing::Errors::ConsumerGroupNotFound`.

## 2.4.5 (2024-07-21)
- [Enhancement] Provide `karafka.consumer_messages` to get (or alter) the messages that will go into created consumer.
- [Fix] `#consumer_group_metadata_pointer` is not stubbed in the consumer client.

## 2.4.4 (2024-07-02)
- [Enhancement] Memoize `consumer_for` so consumers can be set up for multiple topics and `let(:consumer)` is no longer a requirement. (dorner)

## 2.4.3 (2024-05-06)
- [Fix] Fix: raw_key is not being assigned for rspec (CaioPenhalver)
- [Fix] Fix: raw_key is not being assigned for minitest
- [Fix] Fix: headers is not being assigned for minitest and rspec

## 2.4.2 (2024-04-30)
- [Fix] Fix FrozenError when accessing key and headers in `Karafka::Messages::Metadata` (tldn0718)

## 2.4.1 (2024-04-29)
- [Fix] Fix instance variable in minitest helper (tldn0718)

## 2.4.0 (2024-04-26)
- **[EOL]** Drop Ruby `2.7` support.
- [Refactor] Extract common components for Minitest and RSpec.
- [Fix] Support again `require: false` on gem loading.
- [Fix] Fix a case where multiplexed SG would fail with `TopicInManyConsumerGroupsError`

## 2.3.2 (2024-04-03)
- [Enhancement] Support `Minitest::Spec`.

## 2.3.1 (2024-03-07)
- [Enhancement] Prevent usage of testing when Karafka is not loaded.
- [Enhancement] Prevent usage of testing when Karafka is not initialized.
- [Fix] Same CG multiplexing topic builder fails with `TopicInManyConsumerGroupsError`.

## 2.3.0 (2024-01-26)
- [Maintenance] Release matching Karafka `2.3.0` release.

## 2.2.2 (2023-11-16)
- [**Feature**] Provide support for Minitest (ValentinoRusconi-EH)

## 2.2.1 (2023-10-26)
- [Enhancement] Support patterns in `#consumer_for` consumer builder.

## 2.2.0 (2023-09-01)
- [Maintenance] Ensure that `2.2.0` works with consumers for patterns.
- [Maintenance] Replace signing key with a new one (old expired).

## 2.1.6 (2023-08-06)
- [Enhancement] Make `#used?` API always return true.
- [Enhancement] Expand dummy client API with #seek.

## 2.1.5 (2023-07-22)
- [Enhancement] User `prepend_before` instead of `prepend` for RSpec (ojab)
- [Enhancement] Add support for client `#commit_offsets` and `#commit_offsets!` stubs.
- [Fix] Make sure that `#mark_as_consumed!` and `#mark_as_consumed` return true.

## 2.1.4 (2023-06-20)
- [Fix] Fix invalid consumer group assignment for consumers created for non-default consumer group when same topic is being used multiple times.

## 2.1.3 (2023-06-19)
- [Enhancement] Align with Karafka `2.1.5` API.

## 2.1.2 (2023-06-13)
- [Enhancement] Depend on WaterDrop `>=` `2.6.0` directly and not via Karafka to make sure correct version is used.
- [Fix] Use proper WaterDrop `>=` `2.6.0` buffered client reference.

## 2.1.1 (2023-06-07)
- [Enhancement] Support WaterDrop stubs with Mocha.

## 2.1.0 (2023-05-22)
- [Maintenance] Align Karafka expectations to match `2.1.0`.

## 2.0.11 (2023-04-13)
- Align metadata builder format with Karafka `2.0.40`.

## 2.0.10 (2023-04-11)
- Align with changes in Karafka `2.0.39`
- Replace direct `described_class` reference for consumer building with `topic.consumer` Karafka routing based one. This change will allow for usage of `karafka.consumer_for` from any specs.

## 2.0.9 (2023-02-10)
- Inject consumer strategy to the test consumer instance.

## 2.0.8 (2022-11-03)
- Do not lock Ruby and rely on `karafka-core` via `karafka`.
- Due to changes in the engine, lock to `2.0.20`.

## 2.0.7 (2022-11-03)
- Release version with cert with valid access permissions (#114).

## 2.0.6 (2022-10-26)
- Replace the `subject` reference with named `consumer` reference.
- Do not forward sent messages to `consumer` unless it's a Karafka consumer.

## 2.0.5 (2022-10-19)
- Fix for: Test event production without defining a subject (#102)

## 2.0.4 (2022-10-14)
- Align changes with Karafka `2.0.13` changes.

## 2.0.3 (2022-09-30)
- Fix direct name reference `consumer` instead of `subject` (#97).

## 2.0.2 (2022-09-29)
- Provide multi-consumer group testing support (#92)
- Fail fast if requested topic is present in multiple consumer groups but consumer group is not specified.
- Allow for usage of `Karafka.producer` directly and make it buffered.
- Rename `karafka.publish` to `karafka.produce` to align naming conventions [breaking change].

## 2.0.1 (2022-08-05)
- Require non rc version of Karafka.

## 2.0.0 (2022-08-01)
- No changes. Just non-rc release.

## 2.0.0.rc1 (2022-07-19)
- Require Karafka `2.0.0.rc2`

## 2.0.0.alpha4 (2022-07-06)
- Require Karafka `2.0.0.beta5` and fix non-existing coordinator reference

## 2.0.0.alpha3 (2022-03-14)
- Provide support for referencing producer from consumer

## 2.0.0.alpha2 (2022-02-19)
- Add `rubygems_mfa_required`

## 2.0.0.alpha1 (2022-01-30)
- Change the API to be more comprehensive
- Update to work with Karafka 2.0
- Support for Ruby 3.1
- **[EOL]** Drop support for ruby 2.6

## 1.4.*

If you are looking for the changelog of `1.4`, please go [here](https://github.com/karafka/testing/blob/1.4/CHANGELOG.md).
