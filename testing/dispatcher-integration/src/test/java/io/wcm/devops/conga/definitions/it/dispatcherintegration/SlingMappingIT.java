package io.wcm.devops.conga.definitions.it.dispatcherintegration;

import static io.wcm.devops.conga.definitions.it.dispatcherintegration.util.TestUtils.assertAllResourcesHttpOk;
import static io.wcm.devops.conga.definitions.it.dispatcherintegration.util.TestUtils.assertLocationHref;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

import java.util.stream.Stream;

import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.html.HtmlAnchor;
import com.gargoylesoftware.htmlunit.html.HtmlPage;

import io.wcm.devops.conga.definitions.it.dispatcherintegration.util.SystemProperties;

/**
 * Test sling mapping in multiple tenants.
 */
class SlingMappingIT {

  @ParameterizedTest
  @MethodSource("testRootRedirect_Arguments")
  void testRootRedirect(String tenantUrl) throws Exception {
    try (WebClient webClient = new WebClient()) {
      HtmlPage page = webClient.getPage(tenantUrl);
      assertLocationHref(page, tenantUrl + "/en.html");
    }
  }
  private static Stream<Arguments> testRootRedirect_Arguments() {
    return Stream.of(
        "{tenant1.url}",
        "{tenant2.url}"
    ).map(SystemProperties::apply).map(Arguments::of);
  }

  @ParameterizedTest
  @MethodSource("testHomepage_Arguments")
  void testHomepage(String homepageUrl, String titleText) throws Exception {
    try (WebClient webClient = new WebClient()) {
      HtmlPage page = webClient.getPage(homepageUrl);
      assertEquals(titleText, page.getTitleText());

      // ensure that none of the anchor links contains a /content/ or /aemdef-it-sample/ part
      for (HtmlAnchor anchor : page.getAnchors()) {
        String url = anchor.getHrefAttribute();
        assertFalse(StringUtils.contains(url, "/content/"), url + " must not contain /content/");
        assertFalse(StringUtils.contains(url, "/aemdef-it-sample/"), url + " must not contain /aemdef-it-sample/");
      }

      // assert all linked resources are valid
      assertAllResourcesHttpOk(page);
    }
  }
  private static Stream<Arguments> testHomepage_Arguments() {
    return Stream.<String[]>of(
        new String[] { "{tenant1.url}/en.html", "en" },
        new String[] { "{tenant1.url}/de.html", "de" },
        new String[] { "{tenant2.url}/en.html", "en" }
    ).map(SystemProperties::apply).map(Arguments::of);
  }

}
