package com.junjian.platform.controller;

import com.junjian.platform.dto.AuthResponse;
import com.junjian.platform.dto.LoginRequest;
import com.junjian.platform.dto.RegisterRequest;
import com.junjian.platform.entity.EmailVerification;
import com.junjian.platform.entity.User;
import com.junjian.platform.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {
    
    @Autowired
    private AuthService authService;
    
    /**
     * 用户注册
     */
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            AuthResponse response = authService.register(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 用户登录
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 发送邮箱验证码
     */
    @PostMapping("/send-verification-code")
    public ResponseEntity<?> sendVerificationCode(@RequestParam String email, 
                                                  @RequestParam String type) {
        try {
            EmailVerification.VerificationType verificationType;
            switch (type.toLowerCase()) {
                case "register":
                    verificationType = EmailVerification.VerificationType.REGISTER;
                    break;
                case "reset_password":
                    verificationType = EmailVerification.VerificationType.RESET_PASSWORD;
                    break;
                default:
                    throw new RuntimeException("不支持的验证类型");
            }
            
            authService.sendVerificationCode(email, verificationType);
            
            Map<String, String> response = new HashMap<>();
            response.put("message", "验证码已发送到您的邮箱");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 验证邀请码
     */
    @PostMapping("/validate-invite-code")
    public ResponseEntity<?> validateInviteCode(@RequestParam String code) {
        try {
            boolean isValid = authService.validateInviteCode(code);
            Map<String, Object> response = new HashMap<>();
            response.put("valid", isValid);
            
            if (isValid) {
                User.UserRole role = authService.getInviteCodeRole(code);
                response.put("role", role);
                response.put("message", "邀请码有效");
            } else {
                response.put("message", "邀请码无效或已被使用");
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 验证邮箱验证码
     */
    @PostMapping("/validate-verification-code")
    public ResponseEntity<?> validateVerificationCode(@RequestParam String email,
                                                      @RequestParam String code,
                                                      @RequestParam String type) {
        try {
            EmailVerification.VerificationType verificationType;
            switch (type.toLowerCase()) {
                case "register":
                    verificationType = EmailVerification.VerificationType.REGISTER;
                    break;
                case "reset_password":
                    verificationType = EmailVerification.VerificationType.RESET_PASSWORD;
                    break;
                default:
                    throw new RuntimeException("不支持的验证类型");
            }
            
            boolean isValid = authService.validateVerificationCode(email, code, verificationType);
            Map<String, Object> response = new HashMap<>();
            response.put("valid", isValid);
            response.put("message", isValid ? "验证码正确" : "验证码错误或已过期");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 健康检查
     */
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "ok");
        response.put("service", "钧鉴设计交易平台认证服务");
        return ResponseEntity.ok(response);
    }
}