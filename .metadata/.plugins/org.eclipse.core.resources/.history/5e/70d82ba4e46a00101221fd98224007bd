package com.bank.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.*;

@Controller
@RequestMapping("/customer")
public class CustomerUIController {
    
    private final String API_GATEWAY_URL = "http://localhost:8080";
    
    @Autowired
    private RestTemplate restTemplate;
    
    // Show customer registration form
    @GetMapping("/register")
    public String showRegistrationForm() {
        return "customer-register";
    }
    
    // Handle customer registration
    @PostMapping("/register")
    public String registerCustomer(
            @RequestParam("customerId") String customerId,
            @RequestParam("firstName") String firstName,
            @RequestParam("lastName") String lastName,
            @RequestParam("email") String email,
            @RequestParam("phoneNumber") String phoneNumber,
            @RequestParam("password") String password,
            RedirectAttributes redirectAttributes) {
        
        try {
            Map<String, Object> customerData = new HashMap<>();
            customerData.put("customerId", customerId);
            customerData.put("firstName", firstName);
            customerData.put("lastName", lastName);
            customerData.put("email", email);
            customerData.put("phoneNumber", phoneNumber);
            customerData.put("password", password);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(customerData, headers);
            
            ResponseEntity<Map> response = restTemplate.postForEntity(
                API_GATEWAY_URL + "/customers/register", entity, Map.class);
            
            if (response.getStatusCode() == HttpStatus.OK) {
                redirectAttributes.addFlashAttribute("success", 
                    "Customer registered successfully! Customer ID: " + customerId);
                return "redirect:/customer/dashboard/" + customerId;
            }
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", 
                "Registration failed: " + e.getMessage());
        }
        
        return "redirect:/customer/register";
    }
    
    // Show customer dashboard
    @GetMapping("/dashboard/{customerId}")
    public String showDashboard(@PathVariable String customerId, Model model) {
        try {
            // Get customer details
            ResponseEntity<Map> customerResponse = restTemplate.getForEntity(
                API_GATEWAY_URL + "/customers/" + customerId, Map.class);
            model.addAttribute("customer", customerResponse.getBody());
            
            // Get account details
            try {
                ResponseEntity<Map> accountResponse = restTemplate.getForEntity(
                    API_GATEWAY_URL + "/customers/" + customerId + "/account", Map.class);
                model.addAttribute("account", accountResponse.getBody());
            } catch (Exception e) {
                model.addAttribute("accountError", "Account not found");
            }
            
            // Get transaction history
            try {
                ResponseEntity<List> transactionResponse = restTemplate.getForEntity(
                    API_GATEWAY_URL + "/customers/" + customerId + "/transactions", List.class);
                model.addAttribute("transactions", transactionResponse.getBody());
            } catch (Exception e) {
                model.addAttribute("transactionError", "Unable to fetch transactions");
            }
            
        } catch (Exception e) {
            model.addAttribute("error", "Unable to fetch customer details: " + e.getMessage());
        }
        
        return "customer-dashboard";
    }
    
    // Handle deposit
    @PostMapping("/deposit/{customerId}")
    public String deposit(@PathVariable String customerId,
                         @RequestParam("amount") BigDecimal amount,
                         RedirectAttributes redirectAttributes) {
        try {
            restTemplate.postForObject(
                API_GATEWAY_URL + "/customers/" + customerId + "/deposit?amount=" + amount,
                null, String.class);
            redirectAttributes.addFlashAttribute("success", "Amount deposited successfully");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Deposit failed: " + e.getMessage());
        }
        return "redirect:/customer/dashboard/" + customerId;
    }
    
    // Handle withdrawal
    @PostMapping("/withdraw/{customerId}")
    public String withdraw(@PathVariable String customerId,
                          @RequestParam("amount") BigDecimal amount,
                          RedirectAttributes redirectAttributes) {
        try {
            restTemplate.postForObject(
                API_GATEWAY_URL + "/customers/" + customerId + "/withdraw?amount=" + amount,
                null, String.class);
            redirectAttributes.addFlashAttribute("success", "Amount withdrawn successfully");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Withdrawal failed: " + e.getMessage());
        }
        return "redirect:/customer/dashboard/" + customerId;
    }
    
    // Handle transfer
    @PostMapping("/transfer/{customerId}")
    public String transfer(@PathVariable String customerId,
                          @RequestParam("toAccountNumber") String toAccountNumber,
                          @RequestParam("amount") BigDecimal amount,
                          RedirectAttributes redirectAttributes) {
        try {
            restTemplate.postForObject(
                API_GATEWAY_URL + "/customers/" + customerId + "/transfer?toAccountNumber=" + 
                toAccountNumber + "&amount=" + amount, null, String.class);
            redirectAttributes.addFlashAttribute("success", "Amount transferred successfully");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Transfer failed: " + e.getMessage());
        }
        return "redirect:/customer/dashboard/" + customerId;
    }
    
    // Show customer profile
    @GetMapping("/profile/{customerId}")
    public String showProfile(@PathVariable String customerId, Model model) {
        try {
            ResponseEntity<Map> response = restTemplate.getForEntity(
                API_GATEWAY_URL + "/customers/" + customerId, Map.class);
            model.addAttribute("customer", response.getBody());
        } catch (Exception e) {
            model.addAttribute("error", "Unable to fetch customer profile: " + e.getMessage());
        }
        return "customer-profile";
    }
    
    // Handle password change
    @PostMapping("/change-password/{customerId}")
    public String changePassword(@PathVariable String customerId,
                                @RequestParam("currentPassword") String currentPassword,
                                @RequestParam("newPassword") String newPassword,
                                RedirectAttributes redirectAttributes) {
        try {
            restTemplate.put(API_GATEWAY_URL + "/customers/" + customerId + 
                "/change-password?currentPassword=" + currentPassword + 
                "&newPassword=" + newPassword, null);
            redirectAttributes.addFlashAttribute("success", "Password changed successfully");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Password change failed: " + e.getMessage());
        }
        return "redirect:/customer/profile/" + customerId;
    }
    
    // Health check
    @GetMapping("/health")
    @ResponseBody
    public String healthCheck() {
        try {
            String response = restTemplate.getForObject(API_GATEWAY_URL + "/health/customer", String.class);
            return "Frontend UP - Customer Service: " + response;
        } catch (Exception e) {
            return "Frontend UP - Customer Service DOWN: " + e.getMessage();
        }
    }
}
