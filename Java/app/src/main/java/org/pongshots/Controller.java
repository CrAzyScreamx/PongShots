package org.pongshots;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.lang.model.type.UnionType;
import java.util.Map;
import java.util.HashMap;

@RestController
public class Controller {

    private static int PongShots = 3;
    private static boolean gameStarted = false;

    @GetMapping("/")
    public Map<String, Object> home(@RequestParam(defaultValue = "false") boolean detailed) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Welcome to PongShots!");
        response.put("status", "running");

        if (detailed) {
            response.put("version", "1.0.0");
            response.put("timestamp", System.currentTimeMillis());
        }

        return response;
    }

    @PostMapping("/game/start")
    public ResponseEntity<Map<String, Object>> startGame() {
        if (gameStarted) {
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).body(Map.of("message", "Game is already started."));
        }

        gameStarted = true;
        PongShots = 0;
        return ResponseEntity.status(HttpStatus.OK).body(Map.of("message", "Game has started successfully.",
                                                                "pongShots", PongShots));
    }

    @GetMapping("/game/status")
    public ResponseEntity<Map<String, Object>> gameStatus() {
        Map<String, Object> response = new HashMap<>();
        response.put("gameStarted", gameStarted);
        response.put("pongShots", PongShots);
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @PostMapping("/game/reset")
    public ResponseEntity<Map<String, Object>> resetGame() {
        if (!gameStarted) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", "Game has not started yet."));
        }

        PongShots = 0;
        return ResponseEntity.status(HttpStatus.OK).body(Map.of("message", "Game has been reset successfully."));
    }

    @PostMapping("/game/stop")
    public ResponseEntity<Map<String, Object>> stopGame() {
        if (!gameStarted) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", "Game has not started yet."));
        }

        gameStarted = false;
        PongShots = 0;
        return ResponseEntity.status(HttpStatus.OK).body(Map.of("message", "Game has been stopped and reset.",
                                                                "pongShots", PongShots));
    }

    @PostMapping("/game/pongshot")
    public ResponseEntity<Map<String, Object>> pongShot(@RequestBody(required = false) Map<String, Integer> shotData) {

        if (!gameStarted) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    Map.of("message", "Game has not started yet. Please start the game first."));
        }

        if (shotData == null || !shotData.containsKey("power")) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", "You must provide power!"));
        }

        int power = shotData.get("power");
        if (power < 1 || power > 100) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", "Power must be between 1 and 100."));
        }

        PongShots = PongShots + power;
        return ResponseEntity.status(HttpStatus.OK).body(Map.of("message", "Received pong shot with power " + power,
                                                                "pongShots", PongShots));
    }
}
