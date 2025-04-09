A fully immersive AI-based drug dealer system inspired by the mechanics of *Scheduled 1* and rebuilt for FiveM QBCore.

## 🌟 Features
- Hire up to 5 progressive dealers
- Re-up dealers with real inventory stash (QS, ox, or QB)
- Meetups at random GPS locations
- Dealers walk away after stash loads
- Collect dirty money through immersive interaction
- Full UI menu to manage dealers, meet, re-up, collect
- Supports `ox_target` and `qb-target`
- Clean config & SQL ready

## 🧩 Dependencies
- QBCore
- oxmysql
- ox_lib
- ox_target or qb-target
- Any supported inventory: `qs-inventory`, `ox_inventory`, or `qb-inventory`

## 🛠 Installation
1. Import the provided SQL into your database
2. Ensure the following resources in your `server.cfg`:
   ```
   ensure oxmysql
   ensure ox_lib
   ensure ox_target or qb-target
   ensure drugdealer
   ```
3. Edit `shared/config.lua` to match your inventory/target setup
4. You're ready to hustle 💼

## 📂 SQL
```sql
CREATE TABLE IF NOT EXISTS `player_dealers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `dealer_index` INT NOT NULL,
  `name` VARCHAR(50),
  `drugs` JSON DEFAULT NULL,
  `cash` INT DEFAULT 0,
  `total_earned` INT DEFAULT 0,
  `status` VARCHAR(20) DEFAULT 'idle',
  `last_location` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);
```

---

💥 Built with ❤️ by Greenlife710. Join the Metaverse — hustle hard, build your empire.
