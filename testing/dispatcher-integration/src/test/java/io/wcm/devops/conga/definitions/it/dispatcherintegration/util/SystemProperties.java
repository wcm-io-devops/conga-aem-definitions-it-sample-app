package io.wcm.devops.conga.definitions.it.dispatcherintegration.util;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;

public final class SystemProperties {

  private static final Map<String, String> SYSTEM_PROPERTIES = new HashMap<>();
  static {
    SYSTEM_PROPERTIES.put("tenant1.url", System.getProperty("tenant1.url", "http://tenant1.aemdef-it-sample.localhost:5503"));
    SYSTEM_PROPERTIES.put("tenant2.url", System.getProperty("tenant2.url", "http://tenant2.aemdef-it-sample.localhost:5503"));
    SYSTEM_PROPERTIES.put("tenant3.url", System.getProperty("tenant3.url", "http://tenant3-no-mapping.aemdef-it-sample.localhost:5503"));
  }

  private SystemProperties() {
    // static methods only
  }

  /**
   * Replace placeholders for system properties with configures (or default) values.
   * @param value Value with placdholders
   * @return Value with placeholders replaced
   */
  public static String apply(String value) {
    String result = value;

    for (Map.Entry<String, String> entry : SYSTEM_PROPERTIES.entrySet()) {
      result = StringUtils.replace(result, "{" + entry.getKey() + "}", entry.getValue());
    }

    return result;
  }

  /**
   * Replace placeholders for system properties with configures (or default) values.
   * @param values Value with placdholders
   * @return Values with placeholders replaced
   */
  public static String[] apply(String[] values) {
    String[] result = new String[values.length];
    for (int i = 0; i < values.length; i++) {
      result[i] = apply(values[i]);
    }
    return result;
  }

}
