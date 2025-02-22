package com.example;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static org.junit.jupiter.api.Assertions.*;

class StrutsConverterTest {
    private StrutsConverter converter;
    @TempDir
    Path tempDir;

    @BeforeEach
    void setUp() {
        converter = new StrutsConverter();
    }

    @Test
    void testHtmlTextConversion() throws Exception {
        String input = "<html:text property=\"username\" styleClass=\"form-control\"/>";
        String expected = "<input type=\"text\" name=\"username\" value=\"${form.username}\" class=\"form-control\"/>";
        
        Path inputDir = tempDir.resolve("A");
        Path outputDir = tempDir.resolve("A_after");
        Files.createDirectories(inputDir);
        
        Path testFile = inputDir.resolve("test.jsp");
        Files.writeString(testFile, input);
        
        // TODO: Add test implementation
        // converter.convertDirectory();
        
        // Path outputFile = outputDir.resolve("test.jsp");
        // String result = Files.readString(outputFile);
        // assertEquals(expected.trim(), result.trim());
    }
}
