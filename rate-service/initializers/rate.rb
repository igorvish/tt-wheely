plans = YAML.load_file( File.join(File.dirname(__FILE__), '..', 'data', 'tariff_plans.yml') )
Rate.update(plans['tariff_plans'])
