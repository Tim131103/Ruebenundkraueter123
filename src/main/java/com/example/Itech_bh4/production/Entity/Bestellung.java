package com.example.Itech_bh4.production.Entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;


import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "BESTELLUNG")
public class Bestellung {

    @Id
    @Column(name = "BESTELLNR")
    private Integer bestellnr;

    @Column(name = "KUNDENNR")
    private Integer kundennr;

    @Column(name = "BESTELLDATUM")
    private LocalDate datum;

    @Column(name = "RECHNUNGSBETRAG")
    private BigDecimal gesamtpreis;
}
