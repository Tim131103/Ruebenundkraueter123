// src/main/java/com/example/sqlconsole/SqlConsoleController.java
package com.example.Itech_bh4.production.Controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import javax.sql.DataSource;
import java.sql.*;
import java.util.*;

@Controller
@RequestMapping("/admin/sql")
public class CRUDWebController {

    private final DataSource dataSource;

    public CRUDWebController(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final int MAX_SQL_LENGTH = 10_000;
    private static final int MAX_ROWS = 1000;
    private static final int QUERY_TIMEOUT_SECONDS = 10;

    private static final Set<String> ALLOWED_PREFIXES = Set.of(
            "SELECT", "SHOW", "DESCRIBE", "EXPLAIN"
    );

    @GetMapping
    public String form() {
        return "sql-console";
    }

    @PostMapping("/execute")
    public String execute(@RequestParam("sql") String sql, Model model) throws Exception {
        String trimmed = sanitize(sql);
        validateAllowed(trimmed);

        List<Map<String, Object>> rows = new ArrayList<>();
        List<String> columns = new ArrayList<>();

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(trimmed,
                     ResultSet.TYPE_FORWARD_ONLY,
                     ResultSet.CONCUR_READ_ONLY)) {

            ps.setQueryTimeout(QUERY_TIMEOUT_SECONDS);
            ps.setFetchSize(200);

            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData md = rs.getMetaData();
                int colCount = md.getColumnCount();

                // Spaltenüberschriften bevorzugt aus Label, Fallback auf Name
                for (int i = 1; i <= colCount; i++) {
                    String label = md.getColumnLabel(i);
                    String name  = md.getColumnName(i);
                    String header = (label != null && !label.isBlank()) ? label : name;
                    columns.add(header);
                }

                int count = 0;
                while (rs.next() && count < MAX_ROWS) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int i = 1; i <= colCount; i++) {
                        String label = md.getColumnLabel(i);
                        String name  = md.getColumnName(i);
                        Object val = rs.getObject(i);

                        // Immer beide Keys setzen: Label und Name
                        if (label != null && !label.isBlank()) {
                            row.put(label, val);
                        }
                        row.put(name, val);
                    }
                    rows.add(row);
                    count++;
                }
            }


        } catch (SQLTimeoutException e) {
            model.addAttribute("error", "Query timed out after " + QUERY_TIMEOUT_SECONDS + "s");
            return "sql-console";
        } catch (SQLException e) {
            model.addAttribute("error", "SQL error: " + e.getMessage());
            return "sql-console";
        }

        model.addAttribute("columns", columns);
        model.addAttribute("rows", rows);
        model.addAttribute("rowCount", rows.size());
        model.addAttribute("notice", rows.size() == MAX_ROWS ? "Truncated to " + MAX_ROWS + " rows." : null);
        return "sql-console";
    }

    private String sanitize(String input) {
        if (input == null) return "";
        String s = input.trim();
        if (s.length() > MAX_SQL_LENGTH) {
            throw new IllegalArgumentException("SQL too long");
        }
        // Collapse whitespace; remove trailing semicolon
        s = s.replaceAll("[\\u0000-\\u001F]", " ").replaceAll("\\s+", " ").replaceAll(";\\s*$", "");
        return s;
    }

    private void validateAllowed(String sql) {
        // Only one statement and only allowed read-only commands
        if (sql.contains(";")) {
            throw new IllegalArgumentException("Multiple statements are not allowed");
        }
        String upper = sql.toUpperCase(Locale.ROOT);
        boolean allowed = ALLOWED_PREFIXES.stream().anyMatch(upper::startsWith);
        if (!allowed) {
            throw new IllegalArgumentException("Only SELECT/SHOW/DESCRIBE/EXPLAIN are allowed");
        }
        // Block dangerous keywords often used to mutate schema/data
        if (upper.matches(".*\\b(INSERT|UPDATE|DELETE|REPLACE|MERGE|TRUNCATE|CREATE|ALTER|DROP|GRANT|REVOKE)\\b.*")) {
            throw new IllegalArgumentException("Write or DDL statements are not allowed");
        }
    }
}
