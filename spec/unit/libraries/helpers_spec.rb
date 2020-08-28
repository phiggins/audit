# encoding: utf-8
#
# Cookbook:: audit
# Spec:: helpers

require 'spec_helper'
require_relative '../../../libraries/helper'
require_relative '../../data/mock.rb'

describe ReportHelpers do
  it 'handle_reporters returns array of reporters when given array' do
    reporters = %w(chef-compliance json-file)
    expect(ReportHelpers.handle_reporters(reporters)).to eq(%w(chef-compliance json-file))
  end

  it 'handle_reporters returns array of reporters when given string' do
    reporters = 'chef-compliance'
    expect(ReportHelpers.handle_reporters(reporters)).to eq(['chef-compliance'])
  end

  it 'report_profile_sha256s returns array of profile ids found in the report' do
    expect(ReportHelpers.report_profile_sha256s(MockData.inspec_results)).to eq(['7bd598e369970002fc6f2d16d5b988027d58b044ac3fa30ae5fc1b8492e215cd'])
  end

  it 'strip_profiles_meta removes the metadata from the profiles' do
    expected_stripped_report = {
      other_checks: [],
      profiles: [
        {
          attributes: [
            {
              name: 'syslog_pkg',
              options: {
                default: 'rsyslog',
                description: 'syslog package...',
              },
            },
          ],
          controls: [
            {
              id: 'tmp-1.0',
              results: [
                {
                  code_desc: 'File /tmp should be directory',
                  status: 'passed',
                },
              ],
            },
            {
              id: 'tmp-1.1',
              results: [
                {
                  code_desc: 'File /tmp should be owned by "root"',
                  run_time: 1.228845,
                  start_time: '2016-10-19 11:09:43 -0400',
                  status: 'passed',
                },
                {
                  code_desc: 'File /tmp should be owned by "root"',
                  run_time: 1.228845,
                  start_time: '2016-10-19 11:09:43 -0400',
                  status: 'skipped',
                },
                {
                  code_desc: 'File /etc/hosts is expected to be directory',
                  message: 'expected `File /etc/hosts.directory?` to return true, got false',
                  run_time: 1.228845,
                  start_time: '2016-10-19 11:09:43 -0400',
                  status: 'failed',
                },
              ],
            },
          ],
          sha256: '7bd598e369970002fc6f2d16d5b988027d58b044ac3fa30ae5fc1b8492e215cd',
          title: '/tmp Compliance Profile',
          version: '0.1.1',
        },
      ],
      run_time_limit: 1.1,
      statistics: {
        duration: 0.032332,
      },
      version: '1.2.1',
    }
    expect(ReportHelpers.strip_profiles_meta(MockData.inspec_results, [], 1.1)).to eq(expected_stripped_report)
  end

  it 'strip_profiles_meta is not removing the metadata from the missing profiles' do
    expected_stripped_report = MockData.inspec_results
    expected_stripped_report[:run_time_limit] = 1.1
    expect(ReportHelpers.strip_profiles_meta(MockData.inspec_results, ['7bd598e369970002fc6f2d16d5b988027d58b044ac3fa30ae5fc1b8492e215cd'], 1.1)).to eq(expected_stripped_report)
  end

  it 'truncate_controls_results truncates controls results' do
    truncated_report = ReportHelpers.truncate_controls_results(MockData.inspec_results2, 5)
    expect(truncated_report[:profiles][0][:controls][0][:results].length).to eq(5)
    statuses = truncated_report[:profiles][0][:controls][0][:results].map { |r| r[:status] }
    expect(statuses).to eq(%w(failed failed failed skipped skipped))
    expect(truncated_report[:profiles][0][:controls][0][:removed_results_counts]).to eq(failed: 0, skipped: 1, passed: 3)

    expect(truncated_report[:profiles][0][:controls][1][:results].length).to eq(2)
    statuses = truncated_report[:profiles][0][:controls][1][:results].map { |r| r[:status] }
    expect(statuses).to eq(%w(passed passed))
    expect(truncated_report[:profiles][0][:controls][1][:removed_results_counts]).to eq(nil)

    truncated_report = ReportHelpers.truncate_controls_results(MockData.inspec_results2, 0)
    expect(truncated_report[:profiles][0][:controls][0][:results].length).to eq(9)

    truncated_report = ReportHelpers.truncate_controls_results(MockData.inspec_results2, 1)
    expect(truncated_report[:profiles][0][:controls][0][:results].length).to eq(1)
  end
end
