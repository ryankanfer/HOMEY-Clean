import type { Metadata } from "next";
import "./globals.css";
import AdminPillWrapper from "@/components/AdminPillWrapper";
import VersionAnnouncement from "@/components/VersionAnnouncement";
import { UserProfileProvider } from "@/contexts/UserProfileContext";

export const metadata: Metadata = {
  title: "HOMEY - Your Home Journey Companion",
  description: "Find your perfect home with Scout, Drew, Isla, Viza, Paige, and Charlie",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        <UserProfileProvider>
          {children}
        </UserProfileProvider>
        <AdminPillWrapper />
        <VersionAnnouncement />
      </body>
    </html>
  );
}
