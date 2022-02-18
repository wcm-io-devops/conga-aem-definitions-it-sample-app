package io.wcm.devops.conga.definitions.it.dispatcherintegration.util;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.fail;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpResponse.BodyHandlers;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.gargoylesoftware.htmlunit.html.DomAttr;
import com.gargoylesoftware.htmlunit.html.DomElement;
import com.gargoylesoftware.htmlunit.html.HtmlPage;
import com.gargoylesoftware.htmlunit.javascript.host.Location;

public final class TestUtils {

  private TestUtils() {
    // static methods only
  }

  /**
   * Asserts that the current page has the given location.href
   * @param page Page
   * @param expectedHref Expected href URL
   */
  public static void assertLocationHref(HtmlPage page, String expectedHref) {
    Location location = (Location)page.executeJavaScript("window.location").getJavaScriptResult();
    assertEquals(expectedHref, location.getHref());
  }

  /**
   * Asserts that all resources (link:href, script:src, a:href and img:src) can be requested and return HTTP 200.
   * @param page Page
   */
  public static void assertAllResourcesHttpOk(HtmlPage page) throws IOException, InterruptedException {
    Location location = (Location)page.executeJavaScript("window.location").getJavaScriptResult();

    HttpClient httpClient = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(10))
        .build();

    List<String> failures = new ArrayList<>();
    for (Object result : page.getByXPath("//link/@href | //script/@src | //a/@href | //img/@src")) {
      DomAttr attr = ((DomAttr)result);
      DomElement element = (DomElement)attr.getParentNode();
      String url = attr.getValue();

      // skip # urls
      if (StringUtils.startsWith(url, "#")) {
        continue;
      }

      // prepend URL with hostname if required
      if (StringUtils.startsWith(url, "/")) {
        url = location.getProtocol() + "//" + location.getHostname() + ":" + location.getPort() + url;
      }

      // check for HTTP status 200
      int statusCode = getHttpStatusCode(httpClient, url);
      if (statusCode != 200) {
        failures.add(element.toString() + " ==> HTTP status expected <200> but was: <" + statusCode + ">");
      }
    }

    if (!failures.isEmpty()) {
      fail(StringUtils.join(failures, "\n"));
    }
  }

  /**
   * Asserts that the given URL can be requested and returns HTTP 200.
   * @param url URL
   * @return HTTP status code
   */
  private static int getHttpStatusCode(HttpClient httpClient, String url) throws IOException, InterruptedException {
    HttpRequest request = HttpRequest.newBuilder()
        .uri(URI.create(url))
        .timeout(Duration.ofSeconds(30))
        .GET()
        .build();
    HttpResponse<String> response = httpClient.send(request, BodyHandlers.ofString());
    return response.statusCode();
  }

}
