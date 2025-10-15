package com.example.Itech_bh4.production.Repository;

import com.example.Itech_bh4.production.Entity.RezeptErnaehrungskategorie;
import com.example.Itech_bh4.production.Entity.IDKlasse.RezeptErnaehrungskategorieId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RezeptErnaehrungskategorieRepository extends JpaRepository<RezeptErnaehrungskategorie, RezeptErnaehrungskategorieId> {
}
