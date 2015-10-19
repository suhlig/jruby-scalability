# CloudController on JRuby

The Flintstone team recently spent some time researching the potential benefits of running the CloudController under JRuby. We were hoping to find evidence that JRuby (and the underlying JVM) would allow us to make better use of multiple cores, and maybe also lead to significant response time improvements when answering many parallel requests.

This exercise wasn't set up as a scientific benchmark; it is more of a spike that would allow us to judge whether it is worth investigating the next level of detail. We would like to share some early results in the hope to get feedback from the community.

In our measurements, we saw 20..30% improvement in both average response time and throughput when 10 or more concurrent requests were made (using ApacheBench against the `/v2/orgs/*/spaces` endpoint).

Graphs:

    * Throughput:    https://goo.gl/NuWkvf
    * Response Time: https://goo.gl/ItPBHN

We patched a CC VM to use JRuby 9000 under OpenJDK 8. WEBrick was used as we weren't able to quickly find a drop-in replacement for Thin (as used under MRI). All measurements were taken on a 2014 MacBook Pro running Cloudfoundry in a BOSH Lite environment.

For more details see the [spreadsheet](https://docs.google.com/spreadsheets/d/1C1raorozKrf_RO-fiS5Nw38GPsMMgAegyw5iCxO8VT0/) and our [repository](https://github.com/suhlig/jruby-scalability) with the test scripts.

# Steps to Reproduce

1. Install OpenJDK

        $ apt-get update
        $ apt-get install openjdk-7-jre
        $ java -version
        java version "1.7.0_79"
        OpenJDK Runtime Environment (IcedTea 2.5.6) (7u79-2.5.6-0ubuntu1.14.04.1)
        OpenJDK 64-Bit Server VM (build 24.79-b02, mixed mode)

1. Install JRuby

        $ cd /var/vcap/packages/
        $ wget https://s3.amazonaws.com/jruby.org/downloads/9.0.1.0/jruby-bin-9.0.1.0.tar.gz
        $ tar xf jruby-bin-9.0.1.0.tar.gz
        $ jruby-9.0.1.0
        $ bin/jruby -v
        jruby 9.0.1.0 (2.2.2) 2015-09-02 583f336 OpenJDK 64-Bit Server VM 24.79-b02 on 1.7.0_79-b14 +jit [linux-amd64]
        $ export PATH=/var/vcap/packages/jruby-9.0.1.0/bin:$PATH

        Remove bosh/bin from path so we can overwrite bundle (jruby bundle instead of bosh ruby bundle)

        $ export PATH=/var/vcap/packages/jruby-9.0.1.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

1. Find where CC is launched

        $ find / -name cloud_controller -type f
        /var/vcap/data/packages/cloud_controller_ng/710990ce6bfdbda4f184a9c1f57677a68955c248.1-d33833eb9dd2fa9eb162db195344426e4c993364/cloud_controller_ng/bin/cloud_controller

1. Change the Ruby in `/var/vcap/packages/cloud_controller_ng/cloud_controller_ng/bin/cloud_controller` to

        #!/var/vcap/packages/jruby-9.0.1.0/bin/jruby

1. fog uses net_ssh, which requires Ruby >= 2.0. Thus, we switch to JRuby 9.0.1.0.

1. Use steno fork at https://github.com/suhlig/steno/jruby-spike:

        gem 'steno', 'https://github.com/suhlig/steno.git', ref: 'f7eda2ecf6e5ba10553a87f6c4980f0635e7f8ba'

1. Uncomment thin usage in cloud controller

1. Use pg_jruby instead of `pg`

1. Cut Gemfile until it works :-)

        $ rm Gemfile.lock
        $ apt-get install git
        $ bundle --without development --without operations --no-deployment --without test

Trouble makers:

   * vcap_common
   * cf-message-bus
   * cf-registrar

# Measurements

* Run `bin/benchmark`
* Fill in [spreadsheet](https://docs.google.com/spreadsheets/d/1C1raorozKrf_RO-fiS5Nw38GPsMMgAegyw5iCxO8VT0/) from the results
