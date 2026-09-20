package com.devsecops;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class WebSecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testSecurityHeadersArePresent() throws Exception {
        mockMvc.perform(get("/"))
                // Verify X-Content-Type-Options header
                .andExpect(header().string("X-Content-Type-Options", "nosniff"))
                // Verify Cross-Origin-Resource-Policy header
                .andExpect(header().string("Cross-Origin-Resource-Policy", "same-origin"));
    }
}