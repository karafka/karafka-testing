# Karafka Test gem changelog

## 2.1.1 (Unreleased)
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
- Drop support for ruby 2.6

## 1.4.*

If you are looking for the changelog of `1.4`, please go [here](https://github.com/karafka/testing/blob/1.4/CHANGELOG.md).
