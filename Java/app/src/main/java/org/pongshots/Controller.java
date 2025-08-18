package org.pongshots;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;
import java.util.HashMap;

@RestController
public class Controller {

    private static int PongShots = 0;
    
    @GetMapping("/")
    public Map<String, Object> home(@RequestParam(defaultValue = "false") boolean detailed) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Welcome to PongShots!");
        response.put("status", "running");

        if (detailed) {
            response.put("version", "1.0.0");
            response.put("timestamp", System.currentTimeMillis());
            response.put("detailed", true);
        }

        return response;
    }

    @GetMapping("/ping")
    public Map<String, Object> ping() {
        Map<String, Object> response = new HashMap<>();
        PongShots++;
        response.put("message", "PongShots received a ping!");
        response.put("pongShots", PongShots);
        return response;
    }
}
