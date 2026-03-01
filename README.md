# ☔️ Rainsave

**A principal-protected, prize-linked savings app designed to help users safely transition away from gambling through harm reduction.**

![Rainsave Banner](https://via.placeholder.com/1200x400?text=Rainsave+-+Replacing+Risk+With+Reward) ## 💡 The Problem
Quitting gambling "cold turkey" is notoriously difficult. Many recovering gamblers struggle because they miss the dopamine hit of the "reveal" and the possibility of a reward. Traditional banking apps feel unrewarding, making relapse a constant threat.

## 🚀 Our Solution
**Rainsave** acts as a stepping stone. It replaces the financial ruin of gambling with **prize-linked savings** (similar to Premium Bonds). Users deposit money to buy "Rain Tickets." Their principal deposit is 100% safe and can be withdrawn at any time. Instead of risking their money, the *interest* generated on the pooled deposits is used to fund a weekly prize draw. 

Users still get the thrill of the draw, but their money is completely protected. 

## ✨ Key Features

* 📉 **Dynamic Harm Reduction Odds (Calm Mode):** As users build up a "recovery streak," the app physically adapts. The visual intensity of the games tapers off, and the mathematical variance of the odds tightens. Users go from high-variance "jackpot" style draws to low-variance, consistent yields, slowly weaning them off high-dopamine spikes while maintaining a ~3.87% APY Expected Value (EV).
* 🚨 **Automated Relapse Detection:** If the app detects erratic behavior (e.g., buying or selling a massive amount of tickets at once), it intercepts the action. Using a Firebase + Twilio webhook, it instantly and silently fires an SMS text message to the user's pre-assigned accountability partner/trusted contact.
* 🧠 **Learn-to-Earn:** Interactive educational modules that teach users the realities of Expected Value (EV), Variance, and bankroll management. Passing quizzes rewards them with "Raindrops" (our in-app reward currency).
* 🏪 **Rewards Store:** Users can redeem their earned Raindrops for actual cash-out vouchers, calmer UI themes, or entry into daily streak raffles.
* 💬 **Crisis Support:** Embedded live chat routing users to support resources if they feel at risk of relapse.

## 🛠️ How We Built It

* **Frontend:** Built completely in **Flutter (Dart)** for beautiful, cross-platform performance on iOS and Android.
* **Backend:** **Firebase Cloud Firestore** is used for real-time state management and logging transaction triggers.
* **Webhooks & SMS:** **Firebase Cloud Functions (Node.js)** listens to the database for relapse triggers and utilizes the **Twilio API** to dispatch real-time SMS alerts to trusted contacts.
* **Math Engine:** A custom Dart algorithm generating binomial distributions to calculate expected values and manage prize allocation tiers.

## ⚙️ Installation & Running Locally

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0+)
* A connected Android/iOS emulator or physical device.

### Setup
1. Clone the repository:
   ```bash
   git clone [https://github.com/yourusername/rainsave.git](https://github.com/yourusername/rainsave.git)
   cd rainsave
