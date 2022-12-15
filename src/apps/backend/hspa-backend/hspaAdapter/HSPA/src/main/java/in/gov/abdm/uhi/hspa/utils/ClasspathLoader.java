package in.gov.abdm.uhi.hspa.utils;

import java.io.InputStream;

public class ClasspathLoader {
    public static InputStream inputStreamFromClasspath(String path) {
        return Thread.currentThread().getContextClassLoader().getResourceAsStream(path);
    }
}