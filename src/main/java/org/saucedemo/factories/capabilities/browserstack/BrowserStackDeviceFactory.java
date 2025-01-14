package org.saucedemo.factories.capabilities.browserstack;

import com.opencsv.bean.CsvToBeanBuilder;
import com.typesafe.config.Config;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.EnumUtils;
import org.saucedemo.choices.Platform;
import org.saucedemo.factories.EnvFactory;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.List;
import java.util.Random;

@NoArgsConstructor
@Slf4j
public class BrowserStackDeviceFactory {
    private static Config config = EnvFactory.getInstance().getConfig();
    private static final String DEVICE = config.getString("DEVICE");
    private static final String OS_VERSION = config.getString("OS_VERSION");

    private static final String BROWSERSTACK_ANDROID_DEVICES_PATH = config.getString("BROWSERSTACK_ANDROID_DEVICES_PATH");
    private static final String BROWSERSTACK_IOS_DEVICES_PATH = config.getString("BROWSERSTACK_IOS_DEVICES_PATH");

    /**
     * All devices (fixed or random, are to be picked from this list):
     * https://www.browserstack.com/list-of-browsers-and-platforms/app_automate
     */
    public BrowserStackDevice getDevice(Platform platform) {
        if (DEVICE.equalsIgnoreCase("random")) {
            return getARandomBrowserStackDevice(getDeviceFilePath(platform));
        } else if (EnumUtils.isValidEnumIgnoreCase(AndroidModel.class, DEVICE) || EnumUtils.isValidEnumIgnoreCase(IOSModel.class, DEVICE)) {
            return getARandomBrowserStackDevice(getDeviceFilePath(platform, DEVICE));
        } else {
            return getAFixedBrowserStackDevice();
        }
    }

    private static final BrowserStackDevice getAFixedBrowserStackDevice() {
        return new BrowserStackDevice(DEVICE, OS_VERSION);
    }

    private String getDeviceFilePath(Platform platform) {
        switch (platform) {
            case ANDROID:
                return getFilePath(BROWSERSTACK_ANDROID_DEVICES_PATH, AndroidModel.getRandomModel().label);
            case IOS:
                return getFilePath(BROWSERSTACK_IOS_DEVICES_PATH, IOSModel.getRandomModel().label);
            default:
                throw new IllegalStateException("Platform choice is incorrect. You can either choose 'android' or 'ios'." +
                        "Check the value of 'PLATFORM' property set in application.conf; Or in CI, if run from continuous integration.");
        }
    }

    private String getFilePath(String filePath, String fileName) {
        return String.format("%s/%s.csv", filePath, fileName);
    }

    private String getDeviceFilePath(Platform platform, String modelType) {
        log.info("Model type: {}", modelType);
        switch (platform) {
            case ANDROID:
                if (EnumUtils.isValidEnumIgnoreCase(AndroidModel.class, modelType)) {
                    return getFilePath(BROWSERSTACK_ANDROID_DEVICES_PATH, modelType);
                } else {
                    throw new IllegalStateException(String.format("android does not have %s devices. Fix your platform or device choice", modelType));
                }
            case IOS:
                if (EnumUtils.isValidEnumIgnoreCase(IOSModel.class, modelType)) {
                    return getFilePath(BROWSERSTACK_IOS_DEVICES_PATH, modelType);
                } else {
                    throw new IllegalStateException(String.format("ios does not have %s devices. Fix your platform or device choice", modelType));
                }
            default:
                throw new IllegalStateException("Platform choice is incorrect. You can either choose 'android' or 'ios'." +
                        "Check the value of 'PLATFORM' property set in application.conf; Or in CI, if run from continuous integration.");
        }
    }

    private BrowserStackDevice getARandomBrowserStackDevice(String filePath) {
        List<BrowserStackDevice> devices = getDevicesForAModel(filePath);
        return getRandomDeviceFromAParticularModel(devices);
    }

    private static List<BrowserStackDevice> getDevicesForAModel(String csvFilePath) {
        try {
            return new CsvToBeanBuilder(new FileReader(csvFilePath))
                    .withType(BrowserStackDevice.class)
                    .build()
                    .parse();
        } catch (FileNotFoundException e) {
            throw new IllegalStateException("csvFilePath not found.", e);
        }
    }


    private BrowserStackDevice getRandomDeviceFromAParticularModel(List<BrowserStackDevice> devices) {
        Random random = new Random();
        Integer randomDevice = random.nextInt(devices.size());
        return devices.get(randomDevice);
    }
}
