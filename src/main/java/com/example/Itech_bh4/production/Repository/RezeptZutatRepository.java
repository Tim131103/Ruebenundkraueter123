package com.example.Itech_bh4.production.Repository;

import com.example.Itech_bh4.production.Entity.RezeptZutat;
import com.example.Itech_bh4.production.Entity.IDKlasse.RezeptZutatID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RezeptZutatRepository extends JpaRepository<RezeptZutat, RezeptZutatID> {
}
