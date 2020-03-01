
module EtOrbi

  class << self

    def now(zone=nil)

      EoTime.new(Time.now.to_f, zone)
    end

    def parse(str, opts={})

      str, str_zone = extract_zone(str)

      if defined?(::Chronic) && t = ::Chronic.parse(str, opts)

        str = [ t.strftime('%F %T'), str_zone ].compact.join(' ')
      end

      begin
        DateTime.parse(str)
      rescue
        fail ArgumentError, "No time information in #{str.inspect}"
      end
      #end if RUBY_VERSION < '1.9.0'
      #end if RUBY_VERSION < '2.0.0'
        #
        # is necessary since Time.parse('xxx') in Ruby < 1.9 yields `now`

      zone =
        opts[:zone] ||
        get_tzone(str_zone) ||
        determine_local_tzone

      local = Time.parse(str)
      secs = zone.local_to_utc(local).to_f

      EoTime.new(secs, zone)
    end

    def make_time(*a)

      zone = a.length > 1 ? get_tzone(a.last) : nil
      a.pop if zone

      o = a.length > 1 ? a : a.first

      case o
      when Time then make_from_time(o, zone)
      when Date then make_from_date(o, zone)
      when Array then make_from_array(o, zone)
      when String then make_from_string(o, zone)
      when Numeric then make_from_numeric(o, zone)
      when ::EtOrbi::EoTime then make_from_eotime(o, zone)
      else fail ArgumentError.new(
        "Cannot turn #{o.inspect} to a ::EtOrbi::EoTime instance")
      end
    end
    alias make make_time

    protected

    def make_from_time(t, zone)

      z =
        zone ||
        get_as_tzone(t) ||
        get_tzone(t.zone) ||
        get_local_tzone(t)

      z ||= t.zone
        # pass the abbreviation anyway,
        # it will be used in the resulting error message

      EoTime.new(t, z)
    end

    def make_from_date(d, zone)

      make_from_time(
        d.respond_to?(:to_time) ?
        d.to_time :
        Time.parse(d.strftime('%Y-%m-%d %H:%M:%S')),
        zone)
    end

    def make_from_array(a, zone)

      t = Time.utc(*a)
      s = t.strftime("%Y-%m-%d %H:%M:%S.#{'%06d' % t.usec}")

      make_from_string(s, zone)
    end

    def make_from_string(s, zone)

      parse(s, zone: zone)
    end

    def make_from_numeric(f, zone)

      EoTime.new(Time.now.to_f + f, zone)
    end

    def make_from_eotime(eot, zone)

      return eot if zone == nil || zone == eot.zone
      EoTime.new(eot.to_f, zone)
    end
  end
end

