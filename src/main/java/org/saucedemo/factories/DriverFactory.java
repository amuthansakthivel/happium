package org.saucedemo.factories;

import com.typesafe.config.Config;
import io.appium.java_client.AppiumDriver;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.ios.IOSDriver;
import lombok.extern.slf4j.Slf4j;
import org.saucedemo.choices.Host;
import org.saucedemo.choices.Platform;

import java.util.concurrent.TimeUnit;

@Slf4j
public class DriverFactory {
    private static Config config = EnvFactory.getInstance().getConfig();
    private static final Host HOST = Host.valueOfLabel(config.getString("HOST"));

    private DriverFactory() {
        throw new IllegalStateException("Static factory class");
    }

    public static AppiumDriver getDriver(Platform platform) {
        log.info("Getting driver for PLATFORM: {}", platform);
        switch (platform) {
            case ANDROID:
                return new AndroidDriver(URLFactory.getHostURL(HOST), CapabilitiesFactory.getDesiredCapabilities(HOST, platform));
            case IOS:
                return new IOSDriver(URLFactory.getHostURL(HOST), CapabilitiesFactory.getDesiredCapabilities(HOST, platform));
            default:
                throw new IllegalStateException(String.format("%s is not a valid platform choice. Pick your platform from %s." +
                        "Check the value of 'PLATFORM' property in application.conf; Or in CI, if running from continuous integration.", platform, java.util.Arrays.asList(Platform.values())));
        }
    }

    public static void setDriverTimeouts(AppiumDriver driver) {
        driver.manage().timeouts().implicitlyWait(180, TimeUnit.SECONDS);

        log.info("SessionId: {}", driver.getSessionId());
        log.info("Driver capabilities: {}", driver.getCapabilities());
    }
}
