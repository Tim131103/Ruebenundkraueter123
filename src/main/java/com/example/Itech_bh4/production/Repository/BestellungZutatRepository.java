package com.example.Itech_bh4.production.Repository;

import com.example.Itech_bh4.production.Entity.bestellungZutat;
import com.example.Itech_bh4.production.Entity.IDKlasse.BestellungZutatId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BestellungZutatRepository extends JpaRepository<bestellungZutat, BestellungZutatId> {
}
